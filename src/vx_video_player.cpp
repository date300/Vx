#include "vx_video_player.h"

#include <android/log.h>
#include <chrono>
#include <algorithm>

#define LOG_TAG "VxVideoPlayer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

// ============================================================================
// Constructor / Destructor
// ============================================================================

VxVideoPlayer::VxVideoPlayer() {
    // Initialize FFmpeg if not already done
    static bool ffmpegInitialized = false;
    if (!ffmpegInitialized) {
        avformat_network_init();
        ffmpegInitialized = true;
    }

    initFramePool(12);  // Pre-allocate frame pool
    LOGI("VxVideoPlayer created with frame pool of 12");
}

VxVideoPlayer::~VxVideoPlayer() {
    close();

    // Clear frame pool
    std::lock_guard<std::mutex> lock(poolMutex);
    framePool.clear();
}

// ============================================================================
// Frame Pool (Zero-Copy)
// ============================================================================

void VxVideoPlayer::initFramePool(size_t count) {
    std::lock_guard<std::mutex> lock(poolMutex);
    framePool.reserve(count);
    for (size_t i = 0; i < count; ++i) {
        auto frame = std::make_shared<VxVideoFrame>();
        frame->inUse.store(false);
        framePool.push_back(frame);
    }
}

std::shared_ptr<VxVideoFrame> VxVideoPlayer::acquireFrame() {
    std::lock_guard<std::mutex> lock(poolMutex);
    for (auto& frame : framePool) {
        bool expected = false;
        if (frame->inUse.compare_exchange_strong(expected, true)) {
            return frame;
        }
    }
    // Pool exhausted - allocate emergency frame (slower path)
    auto emergency = std::make_shared<VxVideoFrame>();
    emergency->inUse.store(true);
    LOGD("Frame pool exhausted - emergency allocation");
    return emergency;
}

void VxVideoPlayer::releaseFrame(std::shared_ptr<VxVideoFrame> frame) {
    if (frame) {
        frame->inUse.store(false);
    }
}

// ============================================================================
// Open / Close
// ============================================================================

bool VxVideoPlayer::open(const std::string& url) {
    return open(url, "");  // Software decoding
}

bool VxVideoPlayer::open(const std::string& url, const std::string& hwDevice) {
    close();  // Ensure clean state

    std::lock_guard<std::mutex> lock(stateMutex);

    currentUrl = url;
    hwDeviceName = hwDevice;

    // Open input
    int ret = avformat_open_input(&fmtCtx, url.c_str(), nullptr, nullptr);
    if (ret < 0) {
        char errbuf[256];
        av_strerror(ret, errbuf, sizeof(errbuf));
        LOGE("Failed to open input: %s - %s", url.c_str(), errbuf);
        return false;
    }

    // Find stream info
    ret = avformat_find_stream_info(fmtCtx, nullptr);
    if (ret < 0) {
        LOGE("Failed to find stream info");
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Find video stream
    videoStreamIdx = -1;
    for (unsigned int i = 0; i < fmtCtx->nb_streams; i++) {
        if (fmtCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStreamIdx = i;
            break;
        }
    }

    if (videoStreamIdx == -1) {
        LOGE("No video stream found");
        avformat_close_input(&fmtCtx);
        return false;
    }

    AVStream* stream = fmtCtx->streams[videoStreamIdx];
    AVCodecParameters* codecpar = stream->codecpar;

    videoWidth = codecpar->width;
    videoHeight = codecpar->height;
    duration = fmtCtx->duration > 0 ? (double)fmtCtx->duration / AV_TIME_BASE : 0;
    timeBase = stream->time_base;
    frameRate = av_q2d(stream->avg_frame_rate);
    if (frameRate <= 0) {
        frameRate = av_q2d(stream->r_frame_rate);
    }

    // Find decoder
    const AVCodec* codec = avcodec_find_decoder(codecpar->codec_id);
    if (!codec) {
        LOGE("Codec not found");
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Create decoder context
    decCtx = avcodec_alloc_context3(codec);
    if (!decCtx) {
        LOGE("Failed to allocate decoder context");
        avformat_close_input(&fmtCtx);
        return false;
    }

    ret = avcodec_parameters_to_context(decCtx, codecpar);
    if (ret < 0) {
        LOGE("Failed to copy codec parameters");
        avcodec_free_context(&decCtx);
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Hardware acceleration setup
    if (!hwDevice.empty()) {
        AVHWDeviceType hwType = av_hwdevice_find_type_by_name(hwDevice.c_str());
        if (hwType != AV_HWDEVICE_TYPE_NONE) {
            ret = av_hwdevice_ctx_create(&hwDeviceCtx, hwType, nullptr, nullptr, 0);
            if (ret >= 0) {
                decCtx->hw_device_ctx = av_buffer_ref(hwDeviceCtx);
                LOGI("Hardware acceleration enabled: %s", hwDevice.c_str());
            } else {
                LOGE("Failed to create hardware device context, falling back to software");
            }
        }
    }

    // Open codec
    ret = avcodec_open2(decCtx, codec, nullptr);
    if (ret < 0) {
        char errbuf[256];
        av_strerror(ret, errbuf, sizeof(errbuf));
        LOGE("Failed to open codec: %s", errbuf);
        avcodec_free_context(&decCtx);
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Pre-allocate hardware frame buffer
    if (hwDeviceCtx) {
        hwFrame = av_frame_alloc();
    }

    LOGI("Opened: %dx%d @ %.2ffps, duration: %.2fs",
         videoWidth, videoHeight, frameRate, duration);

    return true;
}

void VxVideoPlayer::close() {
    stop();

    // Wait for threads to finish
    if (readerThread.joinable()) {
        readerThread.join();
    }
    if (decoderThread.joinable()) {
        decoderThread.join();
    }
    if (thumbnailThread.joinable()) {
        thumbnailThread.join();
    }

    std::lock_guard<std::mutex> lock(stateMutex);

    flushQueues();

    if (swsCtx) {
        sws_freeContext(swsCtx);
        swsCtx = nullptr;
    }
    if (hwFrame) {
        av_frame_free(&hwFrame);
    }
    if (hwDeviceCtx) {
        av_buffer_unref(&hwDeviceCtx);
    }
    if (decCtx) {
        avcodec_free_context(&decCtx);
    }
    if (fmtCtx) {
        avformat_close_input(&fmtCtx);
        fmtCtx = nullptr;
    }

    videoStreamIdx = -1;
    videoWidth = 0;
    videoHeight = 0;
    duration = 0;
    frameRate = 0;
    currentTimeMs = 0;
    decodedFrames = 0;
    droppedFrames = 0;
}

// ============================================================================
// Playback Control
// ============================================================================

void VxVideoPlayer::play() {
    if (!fmtCtx || playing.load()) return;

    playing.store(true);
    paused.store(false);
    stopRequested.store(false);

    // Start 3-stage pipeline
    readerThread = std::thread(&VxVideoPlayer::readPacketLoop, this);
    decoderThread = std::thread(&VxVideoPlayer::decodeFrameLoop, this);

    LOGI("Playback started");
}

void VxVideoPlayer::pause() {
    paused.store(true);
    LOGI("Playback paused");
}

void VxVideoPlayer::stop() {
    stopRequested.store(true);
    playing.store(false);
    paused.store(false);

    // Wake up all waiting threads
    packetCond.notify_all();
    frameCond.notify_all();
    seekCond.notify_all();

    LOGI("Playback stopped");
}

void VxVideoPlayer::seek(int64_t timestampMs) {
    if (!fmtCtx) return;

    seekTargetMs.store(timestampMs);
    seekRequested.store(true);
    seekComplete.store(false);

    // Wake up threads
    packetCond.notify_all();
    frameCond.notify_all();

    LOGI("Seek requested to %lld ms", (long long)timestampMs);
}

// ============================================================================
// Thread Workers (3-Stage Pipeline)
// ============================================================================

void VxVideoPlayer::readPacketLoop() {
    LOGI("Reader thread started");

    AVPacket* pkt = av_packet_alloc();

    while (!stopRequested.load()) {
        // Handle seek request
        if (seekRequested.load()) {
            int64_t target = seekTargetMs.load();
            int64_t ts = av_rescale_q(target, AVRational{1, 1000},
                                      fmtCtx->streams[videoStreamIdx]->time_base);

            int ret = av_seek_frame(fmtCtx, videoStreamIdx, ts, AVSEEK_FLAG_BACKWARD);
            if (ret >= 0) {
                avcodec_flush_buffers(decCtx);
                flushQueues();
                currentTimeMs = target;
            }
            seekRequested.store(false);
            seekComplete.store(true);
            seekCond.notify_all();
            continue;
        }

        // Check backpressure
        {
            std::unique_lock<std::mutex> lock(packetQueueMutex);
            packetCond.wait(lock, [this] {
                return packetQueue.size() < maxPacketQueue ||
                       stopRequested.load() || seekRequested.load();
            });

            if (stopRequested.load()) break;
            if (seekRequested.load()) continue;
        }

        // Read packet
        int ret = av_read_frame(fmtCtx, pkt);
        if (ret < 0) {
            if (ret == AVERROR_EOF) {
                // End of file - inject null packet to signal EOF to decoder
                pkt->data = nullptr;
                pkt->size = 0;
                pkt->stream_index = videoStreamIdx;
            } else {
                break;
            }
        }

        if (pkt->stream_index == videoStreamIdx) {
            std::lock_guard<std::mutex> lock(packetQueueMutex);
            packetQueue.push(av_packet_clone(pkt));
            packetCond.notify_one();
        }

        av_packet_unref(pkt);

        if (ret == AVERROR_EOF) break;
    }

    av_packet_free(&pkt);
    LOGI("Reader thread exited");
}

void VxVideoPlayer::decodeFrameLoop() {
    LOGI("Decoder thread started");

    AVFrame* decodedFrame = av_frame_alloc();
    AVPacket* pkt = nullptr;

    while (!stopRequested.load()) {
        // Wait for packets
        {
            std::unique_lock<std::mutex> lock(packetQueueMutex);
            packetCond.wait(lock, [this] {
                return !packetQueue.empty() || stopRequested.load() || seekRequested.load();
            });

            if (stopRequested.load()) break;
            if (seekRequested.load()) continue;

            pkt = packetQueue.front();
            packetQueue.pop();
            packetCond.notify_one();  // Signal reader that queue has space
        }

        // Send packet to decoder
        int ret = avcodec_send_packet(decCtx, pkt);
        av_packet_free(&pkt);
        pkt = nullptr;

        if (ret < 0) {
            if (ret != AVERROR(EAGAIN) && ret != AVERROR_EOF) {
                LOGE("Error sending packet to decoder");
            }
            continue;
        }

        // Receive all available frames
        while (ret >= 0) {
            ret = avcodec_receive_frame(decCtx, decodedFrame);
            if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                break;
            }
            if (ret < 0) {
                LOGE("Error receiving frame from decoder");
                break;
            }

            // Handle hardware frames
            AVFrame* sourceFrame = decodedFrame;
            if (hwDeviceCtx && decodedFrame->format == AV_PIX_FMT_CUDA) {
                // Transfer from GPU to CPU
                ret = av_hwframe_transfer_data(hwFrame, decodedFrame, 0);
                if (ret < 0) {
                    LOGE("Failed to transfer hardware frame");
                    continue;
                }
                sourceFrame = hwFrame;
            }

            // Calculate timestamp
            int64_t ptsMs = av_rescale_q(sourceFrame->pts, timeBase, AVRational{1, 1000});
            currentTimeMs = ptsMs;

            // Frame dropping for performance
            if (dropLateFrames.load() && playing.load() && !paused.load()) {
                int64_t now = av_gettime() / 1000;
                static int64_t startTime = now;
                int64_t expectedTime = startTime + (int64_t)(ptsMs / playbackSpeed.load());

                if (expectedTime < now - 50) {  // 50ms late threshold
                    droppedFrames.fetch_add(1);
                    LOGD("Dropping late frame at %lld ms", (long long)ptsMs);
                    continue;
                }
            }

            // Check backpressure on frame queue
            {
                std::unique_lock<std::mutex> lock(frameQueueMutex);
                frameCond.wait(lock, [this] {
                    return frameQueue.size() < maxFrameQueue ||
                           stopRequested.load() || seekRequested.load();
                });

                if (stopRequested.load()) break;
                if (seekRequested.load()) continue;
            }

            // Clone frame and push to queue
            AVFrame* cloned = av_frame_clone(sourceFrame);
            if (cloned) {
                std::lock_guard<std::mutex> lock(frameQueueMutex);
                frameQueue.push(cloned);
                frameCond.notify_one();
                decodedFrames.fetch_add(1);
            }
        }
    }

    av_frame_free(&decodedFrame);
    LOGI("Decoder thread exited");
}

// ============================================================================
// Frame Retrieval
// ============================================================================

std::shared_ptr<VxVideoFrame> VxVideoPlayer::getNextFrame() {
    AVFrame* avFrame = nullptr;

    {
        std::unique_lock<std::mutex> lock(frameQueueMutex);
        if (frameQueue.empty()) {
            return nullptr;  // Non-blocking
        }

        avFrame = frameQueue.front();
        frameQueue.pop();
        frameCond.notify_one();  // Signal decoder that queue has space
    }

    if (!avFrame) return nullptr;

    // Acquire pooled frame
    auto frame = acquireFrame();
    if (!frame) {
        av_frame_free(&avFrame);
        return nullptr;
    }

    frame->width = videoWidth;
    frame->height = videoHeight;
    frame->ptsMs = av_rescale_q(avFrame->pts, timeBase, AVRational{1, 1000});
    frame->timestamp = frame->ptsMs / 1000.0;

    // Setup SwsContext if needed
    if (!swsCtx || frame->width != videoWidth || frame->height != videoHeight) {
        if (swsCtx) sws_freeContext(swsCtx);
        swsCtx = sws_getContext(
                videoWidth, videoHeight, (AVPixelFormat)avFrame->format,
                videoWidth, videoHeight, AV_PIX_FMT_RGBA,
                SWS_FAST_BILINEAR, nullptr, nullptr, nullptr
        );
    }

    // Ensure buffer is large enough
    size_t bufferSize = videoWidth * videoHeight * 4;  // RGBA
    if (frame->data.size() < bufferSize) {
        frame->data.resize(bufferSize);
    }

    // Convert to RGBA
    uint8_t* dstData[1] = { frame->data.data() };
    int dstLinesize[1] = { videoWidth * 4 };

    sws_scale(swsCtx, avFrame->data, avFrame->linesize, 0, videoHeight, dstData, dstLinesize);

    av_frame_free(&avFrame);

    return frame;
}

bool VxVideoPlayer::getNextFrame(uint8_t* buffer, int width, int height) {
    auto frame = getNextFrame();
    if (!frame) return false;

    // Scale if dimensions don't match
    if (width != videoWidth || height != videoHeight) {
        struct SwsContext* resizeCtx = sws_getContext(
                videoWidth, videoHeight, AV_PIX_FMT_RGBA,
                width, height, AV_PIX_FMT_RGBA,
                SWS_FAST_BILINEAR, nullptr, nullptr, nullptr
        );

        uint8_t* srcData[1] = { frame->data.data() };
        int srcLinesize[1] = { videoWidth * 4 };
        uint8_t* dstData[1] = { buffer };
        int dstLinesize[1] = { width * 4 };

        sws_scale(resizeCtx, srcData, srcLinesize, 0, videoHeight, dstData, dstLinesize);
        sws_freeContext(resizeCtx);
    } else {
        std::copy(frame->data.begin(), frame->data.end(), buffer);
    }

    // Release back to pool
    releaseFrame(frame);
    return true;
}

// ============================================================================
// Thumbnail Extraction
// ============================================================================

bool VxVideoPlayer::extractThumbnail(const std::string& url, uint8_t* outBuffer,
                                     int targetWidth, int targetHeight, int64_t timeMs) {
    // Create independent player for thumbnail
    VxVideoPlayer thumbPlayer;
    if (!thumbPlayer.open(url)) {
        return false;
    }

    // Seek to target time
    thumbPlayer.seek(timeMs);

    // Wait for seek to complete
    std::this_thread::sleep_for(std::chrono::milliseconds(100));

    // Decode a few frames to get a clean I-frame
    auto frame = thumbPlayer.getNextFrame();
    if (!frame) {
        // Try reading forward
        for (int i = 0; i < 30 && !frame; ++i) {
            std::this_thread::sleep_for(std::chrono::milliseconds(16));
            frame = thumbPlayer.getNextFrame();
        }
    }

    if (!frame) {
        return false;
    }

    // Scale to target size
    struct SwsContext* thumbCtx = sws_getContext(
            thumbPlayer.getVideoWidth(), thumbPlayer.getVideoHeight(), AV_PIX_FMT_RGBA,
            targetWidth, targetHeight, AV_PIX_FMT_RGBA,
            SWS_LANCZOS, nullptr, nullptr, nullptr
    );

    uint8_t* srcData[1] = { frame->data.data() };
    int srcLinesize[1] = { thumbPlayer.getVideoWidth() * 4 };
    uint8_t* dstData[1] = { outBuffer };
    int dstLinesize[1] = { targetWidth * 4 };

    sws_scale(thumbCtx, srcData, srcLinesize, 0, thumbPlayer.getVideoHeight(), dstData, dstLinesize);
    sws_freeContext(thumbCtx);

    return true;
}

void VxVideoPlayer::extractThumbnailAsync(const std::string& url, int targetWidth,
                                          int targetHeight, int64_t timeMs,
                                          ThumbnailCallback callback) {
    // Join previous thumbnail thread if running
    if (thumbnailThread.joinable()) {
        thumbnailThread.detach();  // Or join, depending on your lifecycle needs
    }

    thumbnailThread = std::thread(&VxVideoPlayer::thumbnailLoop, this,
                                  url, targetWidth, targetHeight, timeMs, callback);
}

void VxVideoPlayer::thumbnailLoop(const std::string& url, int w, int h, int64_t t,
                                  ThumbnailCallback cb) {
    LOGI("Thumbnail thread started for %s", url.c_str());

    // Allocate buffer
    std::vector<uint8_t> buffer(w * h * 4);

    bool success = extractThumbnail(url, buffer.data(), w, h, t);

    if (success && cb) {
        auto frame = std::make_shared<VxVideoFrame>();
        frame->data = std::move(buffer);
        frame->width = w;
        frame->height = h;
        frame->ptsMs = t;
        cb(frame);
    } else if (cb) {
        cb(nullptr);
    }

    LOGI("Thumbnail thread finished");
}

// ============================================================================
// Queue Management
// ============================================================================

void VxVideoPlayer::flushQueues() {
    clearPacketQueue();
    clearFrameQueue();

    if (decCtx) {
        avcodec_flush_buffers(decCtx);
    }
}

void VxVideoPlayer::clearPacketQueue() {
    std::lock_guard<std::mutex> lock(packetQueueMutex);
    while (!packetQueue.empty()) {
        AVPacket* pkt = packetQueue.front();
        packetQueue.pop();
        av_packet_free(&pkt);
    }
}

void VxVideoPlayer::clearFrameQueue() {
    std::lock_guard<std::mutex> lock(frameQueueMutex);
    while (!frameQueue.empty()) {
        AVFrame* frame = frameQueue.front();
        frameQueue.pop();
        av_frame_free(&frame);
    }
}

// ============================================================================
// Performance Configuration
// ============================================================================

void VxVideoPlayer::setQueueSizes(size_t maxPackets, size_t maxFrames) {
    maxPacketQueue = maxPackets;
    maxFrameQueue = maxFrames;
    LOGI("Queue sizes set: packets=%zu, frames=%zu", maxPackets, maxFrames);
}

void VxVideoPlayer::setDropLateFrames(bool enable) {
    dropLateFrames.store(enable);
    LOGI("Frame dropping: %s", enable ? "enabled" : "disabled");
}

void VxVideoPlayer::setPlaybackSpeed(double speed) {
    playbackSpeed.store(std::max(0.1, std::min(4.0, speed)));
    LOGI("Playback speed set to %.2f", playbackSpeed.load());
}

// ============================================================================
// State Queries
// ============================================================================

int VxVideoPlayer::getVideoWidth() const { return videoWidth; }
int VxVideoPlayer::getVideoHeight() const { return videoHeight; }
double VxVideoPlayer::getDuration() const { return duration; }
bool VxVideoPlayer::isPlaying() const { return playing.load(); }
bool VxVideoPlayer::isPaused() const { return paused.load(); }
int64_t VxVideoPlayer::getCurrentTimeMs() const { return currentTimeMs; }
double VxVideoPlayer::getFps() const { return frameRate; }

// ============================================================================
// Performance Metrics
// ============================================================================

size_t VxVideoPlayer::getPacketQueueSize() const {
    std::lock_guard<std::mutex> lock(packetQueueMutex);
    return packetQueue.size();
}

size_t VxVideoPlayer::getFrameQueueSize() const {
    std::lock_guard<std::mutex> lock(frameQueueMutex);
    return frameQueue.size();
}

int64_t VxVideoPlayer::getDecodedFrameCount() const { return decodedFrames.load(); }
int64_t VxVideoPlayer::getDroppedFrameCount() const { return droppedFrames.load(); }