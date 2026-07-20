#include "vx_video_player.h"
#include <android/log.h>
#include <chrono>
#include <algorithm>
#include <cstring>
#include <sys/stat.h>
#include <fstream>

#define LOG_TAG "VxVideoPlayer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

std::string VxVideoPlayer::cacheDirectory = "";
std::mutex VxVideoPlayer::cacheDirMutex;

VxVideoPlayer::VxVideoPlayer() {
    static bool ffmpegInitialized = false;
    if (!ffmpegInitialized) {
        avformat_network_init();
        ffmpegInitialized = true;
    }
    initFramePool(16);
    LOGI("VxVideoPlayer initialized");
}

VxVideoPlayer::~VxVideoPlayer() {
    close();
    std::lock_guard<std::mutex> lock(poolMutex);
    framePool.clear();
}

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
        if (frame->inUse.compare_exchange_strong(expected, true)) return frame;
    }
    // FIX: pool exhausted. Previously this silently allocated a brand new
    // heap frame every single call with no upper bound -- under sustained
    // backpressure (e.g. consumer stalls) this grows without limit and can
    // OOM the app. We now grow the real pool up to a cap and log loudly so
    // the underlying stall is visible instead of hidden by unbounded alloc.
    if (framePool.size() < kMaxFramePool) {
        auto frame = std::make_shared<VxVideoFrame>();
        frame->inUse.store(true);
        framePool.push_back(frame);
        LOGD("Frame pool grew to %zu", framePool.size());
        return frame;
    }
    LOGE("Frame pool exhausted at cap (%zu) - consumer likely stalled", kMaxFramePool);
    auto emergency = std::make_shared<VxVideoFrame>();
    emergency->inUse.store(true);
    return emergency;
}

void VxVideoPlayer::releaseFrame(std::shared_ptr<VxVideoFrame> frame) {
    if (frame) frame->inUse.store(false);
}

bool VxVideoPlayer::open(const std::string& url) {
    return open(url, "mediacodec");
}

void VxVideoPlayer::setCacheDirectory(const std::string& path) {
    std::lock_guard<std::mutex> lock(cacheDirMutex);
    cacheDirectory = path;
    LOGI("Cache directory set to: %s", path.c_str());
}

static std::string get_cache_key(const std::string& url) {
    size_t hash = std::hash<std::string>{}(url);
    return std::to_string(hash) + ".cache";
}

static bool file_exists(const std::string& path) {
    struct stat buffer;
    return (stat(path.c_str(), &buffer) == 0);
}

bool VxVideoPlayer::open(const std::string& url, const std::string& hwDevice) {
    close();
    std::lock_guard<std::mutex> lock(stateMutex);

    std::string finalUrl = url;

    // Check cache
    std::string cacheDirSnapshot;
    {
        std::lock_guard<std::mutex> cacheLock(cacheDirMutex);
        cacheDirSnapshot = cacheDirectory;
    }
    if (!cacheDirSnapshot.empty() && url.rfind("http", 0) == 0) {
        std::string cacheFile = cacheDirSnapshot + "/" + get_cache_key(url);
        if (file_exists(cacheFile)) {
            LOGI("Loading from cache: %s", cacheFile.c_str());
            finalUrl = cacheFile;
        } else {
            LOGI("Cache miss, opening network: %s", url.c_str());
            // NOTE: a full implementation would kick off a background
            // download+cache-populate here; still a TODO, not a silent bug.
        }
    }

    currentUrl = finalUrl;
    if (avformat_open_input(&fmtCtx, finalUrl.c_str(), nullptr, nullptr) < 0) {
        LOGE("avformat_open_input failed for %s", finalUrl.c_str());
        return false;
    }
    if (avformat_find_stream_info(fmtCtx, nullptr) < 0) {
        LOGE("avformat_find_stream_info failed");
        avformat_close_input(&fmtCtx);
        return false;
    }

    videoStreamIdx = -1;
    audioStreamIdx = -1;
    for (unsigned int i = 0; i < fmtCtx->nb_streams; i++) {
        if (fmtCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO && videoStreamIdx == -1) videoStreamIdx = i;
        else if (fmtCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO && audioStreamIdx == -1) audioStreamIdx = i;
    }

    if (videoStreamIdx == -1) {
        LOGE("No video stream found");
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Video setup
    AVStream* vStream = fmtCtx->streams[videoStreamIdx];
    videoWidth = vStream->codecpar->width;
    videoHeight = vStream->codecpar->height;
    duration = (fmtCtx->duration > 0) ? (double)fmtCtx->duration / AV_TIME_BASE : 0.0;
    timeBase = vStream->time_base;
    frameRate = av_q2d(vStream->avg_frame_rate);

    const AVCodec* vCodec = nullptr;
    // Try hardware-accelerated MediaCodec decoders first
    if (vStream->codecpar->codec_id == AV_CODEC_ID_H264) {
        vCodec = avcodec_find_decoder_by_name("h264_mediacodec");
    } else if (vStream->codecpar->codec_id == AV_CODEC_ID_HEVC) {
        vCodec = avcodec_find_decoder_by_name("hevc_mediacodec");
    } else if (vStream->codecpar->codec_id == AV_CODEC_ID_VP9) {
        vCodec = avcodec_find_decoder_by_name("vp9_mediacodec");
    }

    // Fallback to software decoder if hardware decoder not found or not supported
    if (!vCodec) {
        vCodec = avcodec_find_decoder(vStream->codecpar->codec_id);
    }

    // FIX: original code didn't check for vCodec == nullptr here; if the
    // codec is genuinely unsupported this would crash inside
    // avcodec_alloc_context3(nullptr) / avcodec_open2 instead of failing
    // cleanly.
    if (!vCodec) {
        LOGE("No decoder available for codec id %d", vStream->codecpar->codec_id);
        avformat_close_input(&fmtCtx);
        return false;
    }

    usingHwDecoder.store(strstr(vCodec->name, "mediacodec") != nullptr);

    decCtx = avcodec_alloc_context3(vCodec);
    avcodec_parameters_to_context(decCtx, vStream->codecpar);

    // Enable multi-threading for software fallback only (mediacodec is
    // already hardware-parallel and doesn't benefit from FFmpeg's frame
    // threading, so we leave it at the default there).
    if (!usingHwDecoder.load()) {
        decCtx->thread_count = 0; // Let FFmpeg decide based on CPU cores
        decCtx->thread_type = FF_THREAD_FRAME | FF_THREAD_SLICE;
    }

    if (avcodec_open2(decCtx, vCodec, nullptr) < 0) {
        LOGE("avcodec_open2 failed for video decoder %s", vCodec->name);
        avcodec_free_context(&decCtx);
        avformat_close_input(&fmtCtx);
        return false;
    }

    // Audio setup
    if (audioStreamIdx != -1) {
        AVStream* aStream = fmtCtx->streams[audioStreamIdx];
        audioTimeBase = aStream->time_base;
        const AVCodec* aCodec = avcodec_find_decoder(aStream->codecpar->codec_id);
        if (aCodec) {
            audioDecCtx = avcodec_alloc_context3(aCodec);
            avcodec_parameters_to_context(audioDecCtx, aStream->codecpar);
            if (avcodec_open2(audioDecCtx, aCodec, nullptr) >= 0) {
                swrCtx = swr_alloc();
                AVChannelLayout out_ch;
                av_channel_layout_default(&out_ch, audioChannels);
                av_opt_set_chlayout(swrCtx, "in_chlayout", &aStream->codecpar->ch_layout, 0);
                av_opt_set_int(swrCtx, "in_sample_rate", aStream->codecpar->sample_rate, 0);
                av_opt_set_sample_fmt(swrCtx, "in_sample_fmt", (AVSampleFormat)aStream->codecpar->format, 0);
                av_opt_set_chlayout(swrCtx, "out_chlayout", &out_ch, 0);
                av_opt_set_int(swrCtx, "out_sample_rate", 44100, 0);
                av_opt_set_sample_fmt(swrCtx, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);
                av_channel_layout_uninit(&out_ch);
                if (swr_init(swrCtx) >= 0) {
                    initAudioOutput();
                } else {
                    LOGE("swr_init failed, disabling audio");
                    swr_free(&swrCtx);
                    avcodec_free_context(&audioDecCtx);
                    audioStreamIdx = -1;
                }
            } else {
                LOGE("avcodec_open2 failed for audio decoder %s", aCodec->name);
                avcodec_free_context(&audioDecCtx);
                audioStreamIdx = -1;
            }
        } else {
            LOGE("No decoder available for audio codec id %d", aStream->codecpar->codec_id);
            audioStreamIdx = -1;
        }
    }
    return true;
}

void VxVideoPlayer::close() {
    stop();
    if (readerThread.joinable()) readerThread.join();
    if (decoderThread.joinable()) decoderThread.join();
    if (audioDecoderThread.joinable()) audioDecoderThread.join();

    std::lock_guard<std::mutex> lock(stateMutex);
    shutdownAudioOutput();
    flushQueues();
    if (swrCtx) swr_free(&swrCtx);
    if (swsCtx) sws_freeContext(swsCtx);
    swsCtx = nullptr;
    swsSrcFormat = AV_PIX_FMT_NONE;
    if (decCtx) avcodec_free_context(&decCtx);
    if (audioDecCtx) avcodec_free_context(&audioDecCtx);
    if (fmtCtx) avformat_close_input(&fmtCtx);
    fmtCtx = nullptr;
}

void VxVideoPlayer::play() {
    if (!fmtCtx || playing.load()) return;
    playing.store(true);
    paused.store(false);
    stopRequested.store(false);
    readerThread = std::thread(&VxVideoPlayer::readPacketLoop, this);
    decoderThread = std::thread(&VxVideoPlayer::decodeFrameLoop, this);
    if (audioDecCtx) audioDecoderThread = std::thread(&VxVideoPlayer::decodeAudioLoop, this);
    if (bqPlayerPlay) (*bqPlayerPlay)->SetPlayState(bqPlayerPlay, SL_PLAYSTATE_PLAYING);
}

void VxVideoPlayer::pause() {
    paused.store(true);
    if (bqPlayerPlay) (*bqPlayerPlay)->SetPlayState(bqPlayerPlay, SL_PLAYSTATE_PAUSED);
}

void VxVideoPlayer::stop() {
    stopRequested.store(true);
    playing.store(false);
    videoPacketCond.notify_all();
    audioPacketCond.notify_all();
    frameCond.notify_all();
    audioFrameCond.notify_all();
    if (bqPlayerPlay) (*bqPlayerPlay)->SetPlayState(bqPlayerPlay, SL_PLAYSTATE_STOPPED);
}

void VxVideoPlayer::seek(int64_t ms) {
    seekTargetMs.store(ms);
    seekRequested.store(true);
    videoPacketCond.notify_all();
    audioPacketCond.notify_all();
}

void VxVideoPlayer::setVolume(double vol) {
    volume.store(vol);
    if (bqPlayerVolume) {
        SLmillibel mb = (vol <= 0.0001) ? -9600 : (SLmillibel)(2000 * log10(vol));
        if (mb < -9600) mb = -9600;
        if (mb > 0) mb = 0;
        (*bqPlayerVolume)->SetVolumeLevel(bqPlayerVolume, mb);
    }
}

void VxVideoPlayer::setLooping(bool loop) { looping.store(loop); }

void VxVideoPlayer::readPacketLoop() {
    AVPacket* pkt = av_packet_alloc();
    while (!stopRequested.load()) {
        if (seekRequested.load()) {
            int64_t targetMs = seekTargetMs.load();
            AVRational msTimeBase{1, 1000};
            int64_t ts = av_rescale_q(targetMs, msTimeBase, fmtCtx->streams[videoStreamIdx]->time_base);

            av_seek_frame(fmtCtx, videoStreamIdx, ts, AVSEEK_FLAG_BACKWARD);
            avcodec_flush_buffers(decCtx);
            if (audioDecCtx) avcodec_flush_buffers(audioDecCtx);

            flushQueues();

            // Reset clocks to target position
            audioClockMs.store(targetMs);
            currentTimeMs.store(targetMs);

            // Wake up decoders to handle new stream position
            frameCond.notify_all();
            audioFrameCond.notify_all();

            seekRequested.store(false);
            continue;
        }

        if (av_read_frame(fmtCtx, pkt) < 0) {
            if (looping.load()) { seek(0); continue; }
            break;
        }

        // FIX: route straight to the queue that matches this packet's
        // stream instead of a single shared queue both decoders drain from
        // (see header comment). This is the core fix for lost audio/video
        // packets.
        if (pkt->stream_index == videoStreamIdx) {
            std::unique_lock<std::mutex> lock(videoPacketMutex);
            videoPacketCond.wait(lock, [this] {
                return videoPacketQueue.size() < maxPacketQueue || stopRequested.load() || seekRequested.load();
            });
            if (!stopRequested.load() && !seekRequested.load()) {
                videoPacketQueue.push(av_packet_clone(pkt));
                videoPacketCond.notify_all();
            }
        } else if (pkt->stream_index == audioStreamIdx) {
            std::unique_lock<std::mutex> lock(audioPacketMutex);
            audioPacketCond.wait(lock, [this] {
                return audioPacketQueue.size() < maxPacketQueue || stopRequested.load() || seekRequested.load();
            });
            if (!stopRequested.load() && !seekRequested.load()) {
                audioPacketQueue.push(av_packet_clone(pkt));
                audioPacketCond.notify_all();
            }
        }
        // else: packet belongs to a stream we don't decode (subtitles etc) - drop it.

        av_packet_unref(pkt);
    }
    av_packet_free(&pkt);
}

void VxVideoPlayer::decodeFrameLoop() {
    AVFrame* frame = av_frame_alloc();
    AVFrame* swFrame = av_frame_alloc(); // FIX: scratch frame for hw->sw transfer
    while (!stopRequested.load()) {
        AVPacket* pkt = nullptr;
        {
            std::unique_lock<std::mutex> lock(videoPacketMutex);
            videoPacketCond.wait(lock, [this] { return !videoPacketQueue.empty() || stopRequested.load(); });
            if (stopRequested.load()) break;
            pkt = videoPacketQueue.front();
            videoPacketQueue.pop();
            videoPacketCond.notify_all();
        }

        int sendRet = avcodec_send_packet(decCtx, pkt);
        av_packet_free(&pkt);
        if (sendRet < 0 && sendRet != AVERROR(EAGAIN)) {
            continue;
        }

        while (true) {
            int recvRet = avcodec_receive_frame(decCtx, frame);
            if (recvRet < 0) break; // EAGAIN or EOF: need more packets

            // FIX: pull hardware (MediaCodec) frames back to system memory
            // before they're touched by sws_scale.
            AVFrame* usable = toSoftwareFrame(frame, swFrame);
            if (!usable) {
                av_frame_unref(frame);
                continue;
            }

            std::unique_lock<std::mutex> lock(frameQueueMutex);
            frameCond.wait(lock, [this] { return frameQueue.size() < maxFrameQueue || stopRequested.load(); });
            if (stopRequested.load()) { av_frame_unref(frame); break; }
            frameQueue.push(av_frame_clone(usable));
            frameCond.notify_all();
            av_frame_unref(frame);
        }
    }
    av_frame_free(&frame);
    av_frame_free(&swFrame);
}

AVFrame* VxVideoPlayer::toSoftwareFrame(AVFrame* src, AVFrame* scratch) {
    const AVPixFmtDescriptor* desc = av_pix_fmt_desc_get((AVPixelFormat)src->format);
    bool isHwFormat = desc && (desc->flags & AV_PIX_FMT_FLAG_HWACCEL);
    if (!isHwFormat) {
        return src; // already CPU-readable, nothing to do
    }
    av_frame_unref(scratch);
    if (av_hwframe_transfer_data(scratch, src, 0) < 0) {
        LOGE("av_hwframe_transfer_data failed");
        return nullptr;
    }
    scratch->pts = src->pts;
    return scratch;
}

void VxVideoPlayer::decodeAudioLoop() {
    AVFrame* frame = av_frame_alloc();
    AVFrame* swrFrame = av_frame_alloc();
    while (!stopRequested.load()) {
        AVPacket* pkt = nullptr;
        {
            std::unique_lock<std::mutex> lock(audioPacketMutex);
            audioPacketCond.wait(lock, [this] { return !audioPacketQueue.empty() || stopRequested.load(); });
            if (stopRequested.load()) break;
            pkt = audioPacketQueue.front();
            audioPacketQueue.pop();
            audioPacketCond.notify_all();
        }

        int sendRet = avcodec_send_packet(audioDecCtx, pkt);
        av_packet_free(&pkt);
        if (sendRet < 0 && sendRet != AVERROR(EAGAIN)) {
            continue;
        }

        while (true) {
            int recvRet = avcodec_receive_frame(audioDecCtx, frame);
            if (recvRet < 0) break;

            av_frame_unref(swrFrame); // FIX: was reused across iterations
            // without unref, risking stale/short
            // buffers when sample count changes.
            swrFrame->sample_rate = 44100;
            swrFrame->format = AV_SAMPLE_FMT_S16;
            av_channel_layout_default(&swrFrame->ch_layout, audioChannels);

            if (swr_convert_frame(swrCtx, swrFrame, frame) < 0) {
                LOGE("swr_convert_frame failed");
                av_frame_unref(frame);
                continue;
            }

            std::unique_lock<std::mutex> lock(audioFrameQueueMutex);
            audioFrameCond.wait(lock, [this] { return audioFrameQueue.size() < maxAudioFrameQueue || stopRequested.load(); });
            if (stopRequested.load()) { av_frame_unref(frame); break; }
            audioFrameQueue.push(av_frame_clone(swrFrame));
            if (audioFrameQueue.size() == 1 && bqPlayerBufferQueue) bqPlayerCallback(bqPlayerBufferQueue, this);
            audioFrameCond.notify_all();
            av_frame_unref(frame);
        }
    }
    av_frame_free(&frame);
    av_frame_free(&swrFrame);
}

std::shared_ptr<VxVideoFrame> VxVideoPlayer::getNextFrame() {
    AVFrame* avFrame = nullptr;
    {
        std::unique_lock<std::mutex> lock(frameQueueMutex);

        // FIX: the old A/V-sync "drop and retry" logic used unbounded
        // recursion (return getNextFrame();) which can blow the stack if
        // many consecutive late frames need dropping (e.g. after a long
        // stall). Replaced with an explicit loop.
        while (true) {
            if (frameQueue.empty()) return nullptr;
            avFrame = frameQueue.front();

            if (audioStreamIdx != -1) {
                int64_t pts = av_rescale_q(avFrame->pts, timeBase, {1, 1000});
                int64_t masterClock = audioClockMs.load();
                int64_t diff = pts - masterClock;
                const int64_t SYNC_THRESHOLD = 15;

                if (diff > SYNC_THRESHOLD) {
                    // Video ahead of audio: wait for audio to catch up.
                    return nullptr;
                } else if (diff < -SYNC_THRESHOLD) {
                    // Video behind audio: drop and look at the next one.
                    frameQueue.pop();
                    av_frame_free(&avFrame);
                    droppedFrames++;
                    continue;
                }
            }

            frameQueue.pop();
            frameCond.notify_all();
            break;
        }
    }

    auto frame = acquireFrame();
    frame->width = videoWidth; frame->height = videoHeight;
    frame->ptsMs = av_rescale_q(avFrame->pts, timeBase, {1, 1000});

    // FIX: rebuild the SwsContext if the decoder's output pixel format ever
    // changes (e.g. mid-stream format switch), instead of caching whatever
    // format happened to show up on the very first frame forever.
    auto srcFormat = (AVPixelFormat)avFrame->format;
    if (!swsCtx || swsSrcFormat != srcFormat) {
        if (swsCtx) sws_freeContext(swsCtx);
        swsCtx = sws_getContext(videoWidth, videoHeight, srcFormat,
                                videoWidth, videoHeight, AV_PIX_FMT_RGBA,
                                SWS_FAST_BILINEAR, nullptr, nullptr, nullptr);
        swsSrcFormat = srcFormat;
    }

    frame->data.resize(videoWidth * videoHeight * 4);
    uint8_t* dst[1] = { frame->data.data() };
    int dstStride[1] = { videoWidth * 4 };
    if (swsCtx) {
        sws_scale(swsCtx, avFrame->data, avFrame->linesize, 0, videoHeight, dst, dstStride);
    } else {
        LOGE("sws_getContext failed, returning blank frame");
    }

    av_frame_free(&avFrame);
    currentTimeMs.store(frame->ptsMs);
    decodedFrames++;
    return frame;
}

bool VxVideoPlayer::getNextFrame(uint8_t* buffer, int w, int h) {
    auto frame = getNextFrame();
    if (!frame) return false;
    if (w != frame->width || h != frame->height) {
        LOGE("getNextFrame: buffer size %dx%d does not match frame %dx%d",
             w, h, frame->width, frame->height);
        releaseFrame(frame);
        return false; // FIX: previously ignored w/h entirely and could
        // overflow the caller's buffer via std::copy.
    }
    std::copy(frame->data.begin(), frame->data.end(), buffer);
    releaseFrame(frame);
    return true;
}

bool VxVideoPlayer::initAudioOutput() {
    if (slCreateEngine(&engineObject, 0, nullptr, 0, nullptr, nullptr) != SL_RESULT_SUCCESS) return false;
    (*engineObject)->Realize(engineObject, SL_BOOLEAN_FALSE);
    (*engineObject)->GetInterface(engineObject, SL_IID_ENGINE, &engineEngine);
    (*engineEngine)->CreateOutputMix(engineEngine, &outputMixObject, 0, nullptr, nullptr);
    (*outputMixObject)->Realize(outputMixObject, SL_BOOLEAN_FALSE);

    SLDataLocator_AndroidSimpleBufferQueue loc_bufq = {SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2};
    SLDataFormat_PCM format_pcm = {SL_DATAFORMAT_PCM, (SLuint32)audioChannels, SL_SAMPLINGRATE_44_1,
                                   SL_PCMSAMPLEFORMAT_FIXED_16, SL_PCMSAMPLEFORMAT_FIXED_16,
                                   SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT, SL_BYTEORDER_LITTLEENDIAN};
    SLDataSource audioSrc = {&loc_bufq, &format_pcm};
    SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX, outputMixObject};
    SLDataSink audioSnk = {&loc_outmix, nullptr};

    const SLInterfaceID ids[2] = {SL_IID_BUFFERQUEUE, SL_IID_VOLUME};
    const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
    (*engineEngine)->CreateAudioPlayer(engineEngine, &bqPlayerObject, &audioSrc, &audioSnk, 2, ids, req);
    (*bqPlayerObject)->Realize(bqPlayerObject, SL_BOOLEAN_FALSE);
    (*bqPlayerObject)->GetInterface(bqPlayerObject, SL_IID_PLAY, &bqPlayerPlay);
    (*bqPlayerObject)->GetInterface(bqPlayerObject, SL_IID_BUFFERQUEUE, &bqPlayerBufferQueue);
    (*bqPlayerObject)->GetInterface(bqPlayerObject, SL_IID_VOLUME, &bqPlayerVolume);
    (*bqPlayerBufferQueue)->RegisterCallback(bqPlayerBufferQueue, bqPlayerCallback, this);
    setVolume(volume.load());
    return true;
}

void VxVideoPlayer::bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void* context) {
    auto p = (VxVideoPlayer*)context;
    AVFrame* f = nullptr;
    {
        std::lock_guard<std::mutex> l(p->audioFrameQueueMutex);
        if (!p->audioFrameQueue.empty()) { f = p->audioFrameQueue.front(); p->audioFrameQueue.pop(); p->audioFrameCond.notify_all(); }
    }
    if (f) {
        int bytes = f->nb_samples * p->audioChannels * p->audioBytesPerSample; // FIX: no more magic "4"
        (*bq)->Enqueue(bq, f->data[0], bytes);
        p->audioClockMs.store(av_rescale_q(f->pts, p->audioTimeBase, {1, 1000}));
        av_frame_free(&f);
    } else {
        static int16_t s[512] = {0};
        (*bq)->Enqueue(bq, s, sizeof(s));
    }
}

void VxVideoPlayer::shutdownAudioOutput() {
    if (bqPlayerObject) (*bqPlayerObject)->Destroy(bqPlayerObject);
    if (outputMixObject) (*outputMixObject)->Destroy(outputMixObject);
    if (engineObject) (*engineObject)->Destroy(engineObject);
    bqPlayerObject = nullptr; outputMixObject = nullptr; engineObject = nullptr;
    bqPlayerPlay = nullptr; bqPlayerBufferQueue = nullptr; bqPlayerVolume = nullptr;
}

void VxVideoPlayer::flushQueues() {
    clearVideoPacketQueue();
    clearAudioPacketQueue();
    clearFrameQueue();
    clearAudioFrameQueue();
    if (decCtx) avcodec_flush_buffers(decCtx);
    if (audioDecCtx) avcodec_flush_buffers(audioDecCtx);
}

void VxVideoPlayer::clearVideoPacketQueue() {
    std::lock_guard<std::mutex> l(videoPacketMutex);
    while (!videoPacketQueue.empty()) { auto p = videoPacketQueue.front(); videoPacketQueue.pop(); av_packet_free(&p); }
}

void VxVideoPlayer::clearAudioPacketQueue() {
    std::lock_guard<std::mutex> l(audioPacketMutex);
    while (!audioPacketQueue.empty()) { auto p = audioPacketQueue.front(); audioPacketQueue.pop(); av_packet_free(&p); }
}

void VxVideoPlayer::clearFrameQueue() {
    std::lock_guard<std::mutex> l(frameQueueMutex);
    while(!frameQueue.empty()) { auto f = frameQueue.front(); frameQueue.pop(); av_frame_free(&f); }
}

void VxVideoPlayer::clearAudioFrameQueue() {
    std::lock_guard<std::mutex> l(audioFrameQueueMutex);
    while(!audioFrameQueue.empty()) { auto f = audioFrameQueue.front(); audioFrameQueue.pop(); av_frame_free(&f); }
}

// ... Stubs for other methods to keep it building ...
bool VxVideoPlayer::extractThumbnail(const std::string&, uint8_t*, int, int, int64_t) { return false; }
void VxVideoPlayer::extractThumbnailAsync(const std::string&, int, int, int64_t, ThumbnailCallback) {}
void VxVideoPlayer::setQueueSizes(size_t p, size_t f) { maxPacketQueue = p; maxFrameQueue = f; }
void VxVideoPlayer::setDropLateFrames(bool e) { dropLateFrames.store(e); }
void VxVideoPlayer::setPlaybackSpeed(double s) { playbackSpeed.store(s); }
int VxVideoPlayer::getVideoWidth() const { return videoWidth; }
int VxVideoPlayer::getVideoHeight() const { return videoHeight; }
double VxVideoPlayer::getDuration() const { return duration; }
bool VxVideoPlayer::isPlaying() const { return playing.load(); }
bool VxVideoPlayer::isPaused() const { return paused.load(); }
int64_t VxVideoPlayer::getCurrentTimeMs() const { return currentTimeMs.load(); }
double VxVideoPlayer::getFps() const { return frameRate; }
size_t VxVideoPlayer::getPacketQueueSize() const {
    size_t v, a;
    { std::lock_guard<std::mutex> l(videoPacketMutex); v = videoPacketQueue.size(); }
    { std::lock_guard<std::mutex> l(audioPacketMutex); a = audioPacketQueue.size(); }
    return v + a;
}
size_t VxVideoPlayer::getFrameQueueSize() const {
    std::lock_guard<std::mutex> l(frameQueueMutex);
    return frameQueue.size();
}
int64_t VxVideoPlayer::getDecodedFrameCount() const { return decodedFrames.load(); }
int64_t VxVideoPlayer::getDroppedFrameCount() const { return droppedFrames.load(); }
void VxVideoPlayer::thumbnailLoop(const std::string&, int, int, int64_t, ThumbnailCallback) {}