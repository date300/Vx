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
#include <libavutil/imgutils.h>
#include <libavutil/time.h>
#include <libavutil/hwcontext.h>
}

/**
 * Zero-copy video frame with reference counting.
 * Uses a pooled buffer to eliminate per-frame heap allocations.
 */
struct VxVideoFrame {
    std::vector<uint8_t> data;
    int width = 0;
    int height = 0;
    int64_t ptsMs = 0;          // Presentation timestamp in milliseconds
    double timestamp = 0.0;     // Absolute playback time

    // Pool linkage - managed by VxVideoPlayer
    std::atomic<bool> inUse{false};
};

class VxVideoPlayer {
public:
    VxVideoPlayer();
    ~VxVideoPlayer();

    // -----------------------------------------------------------------
    // Initialization
    // -----------------------------------------------------------------
    bool open(const std::string& url);

    /**
     * Open with hardware acceleration.
     * @param hwDevice Hardware device type: "cuda", "d3d11va", "dxva2", "videotoolbox", "vaapi"
     */
    bool open(const std::string& url, const std::string& hwDevice);
    void close();

    // -----------------------------------------------------------------
    // Playback Control
    // -----------------------------------------------------------------
    void play();
    void pause();
    void stop();

    /**
     * Seek to absolute timestamp. Non-blocking; actual seek happens on decoder thread.
     */
    void seek(int64_t timestampMs);

    // -----------------------------------------------------------------
    // Frame Retrieval
    // -----------------------------------------------------------------

    /**
     * Non-blocking frame retrieval. Returns nullptr if no frame is ready.
     * Uses frame pool for zero-copy operation.
     */
    std::shared_ptr<VxVideoFrame> getNextFrame();

    /**
     * Legacy blocking interface. Copies frame into user-provided buffer.
     */
    bool getNextFrame(uint8_t* buffer, int width, int height);

    // -----------------------------------------------------------------
    // Thumbnail Extraction
    // -----------------------------------------------------------------

    /**
     * Synchronous thumbnail extraction. Blocks until decoded.
     */
    bool extractThumbnail(const std::string& url, uint8_t* outBuffer,
                          int targetWidth, int targetHeight, int64_t timeMs);

    using ThumbnailCallback = std::function<void(std::shared_ptr<VxVideoFrame>)>;

    /**
     * Asynchronous thumbnail extraction. Runs on internal thread.
     */
    void extractThumbnailAsync(const std::string& url, int targetWidth,
                               int targetHeight, int64_t timeMs,
                               ThumbnailCallback callback);

    // -----------------------------------------------------------------
    // Performance Configuration
    // -----------------------------------------------------------------

    /**
     * Set queue sizes for backpressure control.
     * Default: 500 packets / 10 frames.
     */
    void setQueueSizes(size_t maxPackets, size_t maxFrames);

    /**
     * Enable frame dropping when decoder cannot keep up with playback.
     * Essential for real-time performance on slow systems.
     */
    void setDropLateFrames(bool enable);

    /**
     * Playback speed multiplier. 1.0 = normal.
     */
    void setPlaybackSpeed(double speed);

    // -----------------------------------------------------------------
    // State Queries
    // -----------------------------------------------------------------
    int getVideoWidth() const;
    int getVideoHeight() const;
    double getDuration() const;
    bool isPlaying() const;
    bool isPaused() const;
    int64_t getCurrentTimeMs() const;
    double getFps() const;

    // -----------------------------------------------------------------
    // Performance Metrics
    // -----------------------------------------------------------------
    size_t getPacketQueueSize() const;
    size_t getFrameQueueSize() const;
    int64_t getDecodedFrameCount() const;
    int64_t getDroppedFrameCount() const;

private:
    // -----------------------------------------------------------------
    // Thread Workers (3-stage pipeline)
    // -----------------------------------------------------------------
    void readPacketLoop();      // Stage 1: Demuxing (I/O bound)
    void decodeFrameLoop();     // Stage 2: Decoding (CPU/GPU bound)
    void thumbnailLoop(const std::string& url, int w, int h, int64_t t,
                       ThumbnailCallback cb);

    // -----------------------------------------------------------------
    // Queue Management
    // -----------------------------------------------------------------
    void flushQueues();
    void clearPacketQueue();
    void clearFrameQueue();

    // -----------------------------------------------------------------
    // Frame Pool (Zero-Copy)
    // -----------------------------------------------------------------
    std::shared_ptr<VxVideoFrame> acquireFrame();
    void releaseFrame(std::shared_ptr<VxVideoFrame> frame);
    void initFramePool(size_t count);

    // -----------------------------------------------------------------
    // Synchronization Primitives
    // -----------------------------------------------------------------
    mutable std::mutex stateMutex;
    std::condition_variable packetCond;   // Packet queue not empty/full
    std::condition_variable frameCond;    // Frame queue not empty/full
    std::condition_variable seekCond;     // Seek completion signaling

    // -----------------------------------------------------------------
    // FFmpeg Handles
    // -----------------------------------------------------------------
    AVFormatContext* fmtCtx = nullptr;
    AVCodecContext* decCtx = nullptr;      // Software decoder
    AVCodecContext* hwCtx = nullptr;       // Hardware decoder context
    SwsContext* swsCtx = nullptr;
    int videoStreamIdx = -1;
    std::string hwDeviceName;
    AVBufferRef* hwDeviceCtx = nullptr;
    AVFrame* hwFrame = nullptr;            // Hardware frame buffer

    // -----------------------------------------------------------------
    // Queues with Backpressure
    // -----------------------------------------------------------------
    std::queue<AVPacket*> packetQueue;
    std::queue<AVFrame*> frameQueue;
    size_t maxPacketQueue = 500;
    size_t maxFrameQueue = 10;
    mutable std::mutex packetQueueMutex;
    mutable std::mutex frameQueueMutex;

    // -----------------------------------------------------------------
    // Frame Pool
    // -----------------------------------------------------------------
    std::vector<std::shared_ptr<VxVideoFrame>> framePool;
    std::mutex poolMutex;

    // -----------------------------------------------------------------
    // Video Properties
    // -----------------------------------------------------------------
    int videoWidth = 0;
    int videoHeight = 0;
    double duration = 0.0;
    double frameRate = 0.0;
    int64_t currentTimeMs = 0;
    AVRational timeBase;

    // -----------------------------------------------------------------
    // Atomic State Flags (Lock-Free Queries)
    // -----------------------------------------------------------------
    std::atomic<bool> playing{false};
    std::atomic<bool> paused{false};
    std::atomic<bool> stopRequested{false};
    std::atomic<bool> seekRequested{false};
    std::atomic<int64_t> seekTargetMs{0};
    std::atomic<bool> dropLateFrames{false};
    std::atomic<double> playbackSpeed{1.0};
    std::atomic<bool> seekComplete{true};

    // -----------------------------------------------------------------
    // Threads
    // -----------------------------------------------------------------
    std::thread readerThread;
    std::thread decoderThread;
    std::thread thumbnailThread;

    // -----------------------------------------------------------------
    // Performance Counters
    // -----------------------------------------------------------------
    std::atomic<int64_t> decodedFrames{0};
    std::atomic<int64_t> droppedFrames{0};

    // -----------------------------------------------------------------
    // Context
    // -----------------------------------------------------------------
    std::string currentUrl;
};

#endif // VX_VIDEO_PLAYER_H
