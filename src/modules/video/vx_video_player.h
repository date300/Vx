#ifndef VX_VIDEO_PLAYER_H
#define VX_VIDEO_PLAYER_H

#include <string>
#include <mutex>
#include <thread>
#include <atomic>
#include <queue>
#include <vector>
#include <condition_variable>
#include <memory>
#include <functional>
#include <cstdint>

// FFmpeg forward declarations
extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#include <libavutil/imgutils.h>
#include <libavutil/time.h>
#include <libavutil/hwcontext.h>
#include <libavutil/opt.h>
#include <libavutil/pixdesc.h>
}

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>

/**
 * Zero-copy video frame with reference counting.
 */
struct VxVideoFrame {
    std::vector<uint8_t> data;
    int width = 0;
    int height = 0;
    int64_t ptsMs = 0;
    double timestamp = 0.0;
    std::atomic<bool> inUse{false};
};

class VxVideoPlayer {
public:
    VxVideoPlayer();
    ~VxVideoPlayer();

    bool open(const std::string& url);
    bool open(const std::string& url, const std::string& hwDevice);
    void close();

    void play();
    void pause();
    void stop();
    void seek(int64_t timestampMs);

    void setVolume(double vol);
    void setLooping(bool loop);

    std::shared_ptr<VxVideoFrame> getNextFrame();
    bool getNextFrame(uint8_t* buffer, int width, int height);

    bool extractThumbnail(const std::string& url, uint8_t* outBuffer,
                          int targetWidth, int targetHeight, int64_t timeMs);

    using ThumbnailCallback = std::function<void(std::shared_ptr<VxVideoFrame>)>;
    void extractThumbnailAsync(const std::string& url, int targetWidth,
                               int targetHeight, int64_t timeMs,
                               ThumbnailCallback callback);

    void setQueueSizes(size_t maxPackets, size_t maxFrames);
    void setDropLateFrames(bool enable);
    void setPlaybackSpeed(double speed);

    int getVideoWidth() const;
    int getVideoHeight() const;
    double getDuration() const;
    bool isPlaying() const;
    bool isPaused() const;
    int64_t getCurrentTimeMs() const;
    double getFps() const;

    size_t getPacketQueueSize() const;   // video+audio combined
    size_t getFrameQueueSize() const;
    int64_t getDecodedFrameCount() const;
    int64_t getDroppedFrameCount() const;
    static void setCacheDirectory(const std::string& path);

private:
    static std::string cacheDirectory;
    static std::mutex cacheDirMutex;      // FIX: cacheDirectory is static/global and
    // was being read/written without any
    // synchronization -> data race if
    // setCacheDirectory() is called from another
    // thread while open() is running.

    void readPacketLoop();
    void decodeFrameLoop();
    void decodeAudioLoop();
    void thumbnailLoop(const std::string& url, int w, int h, int64_t t, ThumbnailCallback cb);

    void flushQueues();
    void clearVideoPacketQueue();
    void clearAudioPacketQueue();
    void clearFrameQueue();
    void clearAudioFrameQueue();

    bool initAudioOutput();
    void shutdownAudioOutput();
    static void bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void* context);

    std::shared_ptr<VxVideoFrame> acquireFrame();
    void releaseFrame(std::shared_ptr<VxVideoFrame> frame);
    void initFramePool(size_t count);

    // FIX: helper that converts a decoded AVFrame (which may live on a
    // MediaCodec hardware surface, i.e. AV_PIX_FMT_MEDIACODEC) into a
    // CPU-readable software frame before it is hit with sws_scale().
    // The old code called sws_scale() directly on whatever the decoder
    // produced, which segfaults / produces garbage for any frame that
    // came out of the h264_mediacodec / hevc_mediacodec / vp9_mediacodec
    // hardware decoders.
    AVFrame* toSoftwareFrame(AVFrame* src, AVFrame* scratch);

    mutable std::mutex stateMutex;

    // FIX: video and audio packets used to share a single queue/condvar,
    // and each decode thread would pop-and-delete any packet that did not
    // belong to it. That silently threw away roughly half of all packets
    // (whichever thread happened to wake up first), causing missing audio,
    // frozen/skippy video, and effectively random A/V desync. They are now
    // fully independent queues.
    std::condition_variable videoPacketCond;
    std::condition_variable audioPacketCond;
    std::condition_variable frameCond;
    std::condition_variable audioFrameCond;
    std::condition_variable seekCond;

    AVFormatContext* fmtCtx = nullptr;
    AVCodecContext* decCtx = nullptr;      // Video
    AVCodecContext* audioDecCtx = nullptr; // Audio
    SwrContext* swrCtx = nullptr;
    SwsContext* swsCtx = nullptr;
    enum AVPixelFormat swsSrcFormat = AV_PIX_FMT_NONE; // FIX: track format used to
    // build swsCtx so we rebuild
    // it if the decoder's output
    // format changes mid-stream.

    int videoStreamIdx = -1;
    int audioStreamIdx = -1;

    AVBufferRef* hwDeviceCtx = nullptr;

    std::queue<AVPacket*> videoPacketQueue;
    std::queue<AVPacket*> audioPacketQueue;
    std::queue<AVFrame*> frameQueue;
    std::queue<AVFrame*> audioFrameQueue;

    size_t maxPacketQueue = 500;
    size_t maxFrameQueue = 10;
    size_t maxAudioFrameQueue = 20;

    mutable std::mutex videoPacketMutex;
    mutable std::mutex audioPacketMutex;
    mutable std::mutex frameQueueMutex;
    mutable std::mutex audioFrameQueueMutex;

    std::vector<std::shared_ptr<VxVideoFrame>> framePool;
    static constexpr size_t kMaxFramePool = 32; // FIX: cap runaway pool growth
    std::mutex poolMutex;

    // Audio Output (OpenSL ES)
    SLObjectItf engineObject = nullptr;
    SLEngineItf engineEngine = nullptr;
    SLObjectItf outputMixObject = nullptr;
    SLObjectItf bqPlayerObject = nullptr;
    SLPlayItf bqPlayerPlay = nullptr;
    SLAndroidSimpleBufferQueueItf bqPlayerBufferQueue = nullptr;
    SLVolumeItf bqPlayerVolume = nullptr;

    int audioChannels = 2;      // FIX: was hard-coded "* 4" (2ch * 16-bit) magic number
    int audioBytesPerSample = 2; // S16 = 2 bytes

    int videoWidth = 0;
    int videoHeight = 0;
    double duration = 0.0;
    double frameRate = 0.0;
    std::atomic<int64_t> currentTimeMs{0};
    std::atomic<int64_t> audioClockMs{0};
    AVRational timeBase{1, 1};
    AVRational audioTimeBase{1, 1};

    std::atomic<bool> playing{false};
    std::atomic<bool> paused{false};
    std::atomic<bool> stopRequested{false};
    std::atomic<bool> seekRequested{false};
    std::atomic<int64_t> seekTargetMs{0};
    std::atomic<bool> dropLateFrames{false};
    std::atomic<double> playbackSpeed{1.0};
    std::atomic<double> volume{1.0};
    std::atomic<bool> looping{true};
    std::atomic<bool> seekComplete{true};
    std::atomic<bool> usingHwDecoder{false};

    std::thread readerThread;
    std::thread decoderThread;
    std::thread audioDecoderThread;
    std::thread thumbnailThread;

    std::atomic<int64_t> decodedFrames{0};
    std::atomic<int64_t> droppedFrames{0};

    std::string currentUrl;
};

#endif // VX_VIDEO_PLAYER_H