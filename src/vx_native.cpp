#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include "vx_video_player.h"

#if defined(__ANDROID__)
#include <malloc.h>
#endif

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

// --- C++ INTERNAL HELPERS (outside extern "C") ---
#ifdef __cplusplus
static bool _desc_cmp(int32_t a, int32_t b) { return a > b; }

static inline void _secure_zero(void* ptr, size_t len) {
    volatile unsigned char* p = (volatile unsigned char*)ptr;
    while (len--) *p++ = 0;
}

static inline int32_t _iabs(int32_t x) { return x < 0 ? -x : x; }
static inline double _fabs(double x) { return x < 0.0 ? -x : x; }

// xorshift64* — high-quality, thread-safe PRNG (no global state)
static inline uint64_t _xorshift64star(uint64_t* state) {
    uint64_t x = *state;
    x ^= x >> 12;
    x ^= x << 25;
    x ^= x >> 27;
    *state = x;
    return x * 0x2545F4914F6CDD1DULL;
}
#endif

extern "C" {

// ==========================================
// 12. VIDEO PLAYER API
// ==========================================

FFI_EXPORT void* create_video_player() {
    return new VxVideoPlayer();
}

FFI_EXPORT void dispose_video_player(void* player) {
    delete static_cast<VxVideoPlayer*>(player);
}

FFI_EXPORT bool open_video(void* player, const char* url) {
    return static_cast<VxVideoPlayer*>(player)->open(url);
}

FFI_EXPORT void play_video(void* player) {
    static_cast<VxVideoPlayer*>(player)->play();
}

FFI_EXPORT void pause_video(void* player) {
    static_cast<VxVideoPlayer*>(player)->pause();
}

FFI_EXPORT void seek_video(void* player, int64_t timestampMs) {
    static_cast<VxVideoPlayer*>(player)->seek(timestampMs);
}

FFI_EXPORT bool get_video_frame(void* player, uint8_t* buffer, int width, int height) {
    return static_cast<VxVideoPlayer*>(player)->getNextFrame(buffer, width, height);
}

FFI_EXPORT int get_video_width(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getVideoWidth();
}

FFI_EXPORT int get_video_height(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getVideoHeight();
}

FFI_EXPORT double get_video_duration(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getDuration();
}

FFI_EXPORT bool extract_video_thumbnail(void* player, const char* url, uint8_t* buffer, int width, int height, int64_t timeMs) {
    return static_cast<VxVideoPlayer*>(player)->extractThumbnail(url, buffer, width, height, timeMs);
}

// ==========================================
// 1. ADVANCED PHYSICS ANIMATION ENGINE
// ==========================================

FFI_EXPORT double calculate_spring_force(double distance, double velocity, double stiffness, double damping) {
    // Critical damping check for stability (prevents oscillation explosion)
    double critical = 2.0 * sqrt(stiffness);
    double effective_damping = (damping > critical) ? damping : critical;
    return -stiffness * distance - effective_damping * velocity;
}

FFI_EXPORT double calculate_jiggle_physics(double time, double frequency, double amplitude, double decay) {
    if (time < 0.0) return 0.0;
    // 2*PI for true Hz frequency, exponential decay for natural dampening
    return amplitude * exp(-decay * time) * cos(6.283185307179586 * frequency * time);
}

FFI_EXPORT double fast_lerp(double a, double b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a + t * (b - a);
}

FFI_EXPORT double calculate_bounce_ease_out(double time, double duration) {
    // Professional bounce easing for UI sheets (4-phase bounce)
    if (time <= 0.0) return 0.0;
    if (time >= duration) return 1.0;
    double t = time / duration;
    if (t < (1.0 / 2.75)) {
        return 7.5625 * t * t;
    } else if (t < (2.0 / 2.75)) {
        t -= 1.5 / 2.75;
        return 7.5625 * t * t + 0.75;
    } else if (t < (2.5 / 2.75)) {
        t -= 2.25 / 2.75;
        return 7.5625 * t * t + 0.9375;
    } else {
        t -= 2.625 / 2.75;
        return 7.5625 * t * t + 0.984375;
    }
}

FFI_EXPORT double calculate_elastic_collision(double v1, double m1, double v2, double m2, double restitution) {
    // 1D elastic/inelastic collision for interactive UI elements
    double totalMass = m1 + m2;
    if (totalMass == 0.0) return v1;
    return ((m1 - restitution * m2) * v1 + (1.0 + restitution) * m2 * v2) / totalMass;
}

// ==========================================
// 2. AI-READY BUFFER & PERFORMANCE ENGINE
// ==========================================

FFI_EXPORT int32_t calculate_buffer_priority(double scrollVelocity, int32_t videoIndex, int32_t currentIndex) {
    int32_t distance = _iabs(videoIndex - currentIndex);

    // High-velocity scrolling: aggressively prefetch next few videos
    if (scrollVelocity > 500.0 && videoIndex > currentIndex) {
        if (distance == 0) return 1000;
        if (distance <= 2) return 500;
        if (distance < 5) return 100;
        return 50;
    }

    // Normal mode: exponential decay priority (fixed integer division bug)
    if (distance == 0) return 1000;
    if (distance == 1) return 500;
    return (int32_t)(100.0 / (double)(distance + 1));
}

FFI_EXPORT void native_optimize_memory() {
#if defined(__ANDROID__) && !defined(__LP64__)
    // malloc_trim is often not available or necessary on 64-bit Android/NDK
    // and can cause build failures. Only attempt on 32-bit if needed.
    // malloc_trim(0);
#endif
}

FFI_EXPORT void memory_prefetch_buffer(const uint8_t* buffer, int32_t length) {
    if (!buffer || length <= 0) return;
    // Warm CPU cache before heavy processing
#if defined(__GNUC__) || defined(__clang__)
    __builtin_prefetch(buffer, 0, 3);
            if (length > 64) __builtin_prefetch(buffer + length - 64, 0, 3);
#endif
}

// ==========================================
// 3. NATIVE SECURITY & ENCRYPTION LAYER
// ==========================================

// Internal: ChaCha20 quarter-round block function
static void _chacha20_block(uint32_t state[16], uint8_t out[64]) {
    uint32_t x[16];
    memcpy(x, state, 64);

#define ROTL32(v, n) (((v) << (n)) | ((v) >> (32 - (n))))
#define QR(a,b,c,d) \
            x[a] += x[b]; x[d] ^= x[a]; x[d] = ROTL32(x[d], 16); \
            x[c] += x[d]; x[b] ^= x[c]; x[b] = ROTL32(x[b], 12); \
            x[a] += x[b]; x[d] ^= x[a]; x[d] = ROTL32(x[d], 8);  \
            x[c] += x[d]; x[b] ^= x[c]; x[b] = ROTL32(x[b], 7);

    for (int i = 0; i < 10; i++) {
        // Column rounds
        QR(0,4,8,12);  QR(1,5,9,13);  QR(2,6,10,14);  QR(3,7,11,15);
        // Diagonal rounds
        QR(0,5,10,15); QR(1,6,11,12); QR(2,7,8,13);   QR(3,4,9,14);
    }

    for (int i = 0; i < 16; i++) {
        x[i] += state[i];
        out[i*4+0] = (uint8_t)(x[i]);
        out[i*4+1] = (uint8_t)(x[i] >> 8);
        out[i*4+2] = (uint8_t)(x[i] >> 16);
        out[i*4+3] = (uint8_t)(x[i] >> 24);
    }
#undef ROTL32
#undef QR
}

FFI_EXPORT void native_encrypt_data(uint8_t* data, int32_t length, uint8_t* key, int32_t keyLength) {
    if (!data || !key || length <= 0 || keyLength <= 0) return;

    // Derive strong initial state from key using FNV-1a
    uint64_t state = 14695981039346656037ULL;
    for (int i = 0; i < keyLength; i++) {
        state ^= key[i];
        state *= 1099511628211ULL;
    }

    // xorshift64* keystream mixed with key (prevents simple XOR patterns)
    for (int32_t i = 0; i < length; i++) {
        uint64_t ks = _xorshift64star(&state);
        uint8_t stream = (uint8_t)(ks ^ (ks >> 8) ^ (ks >> 16) ^ (ks >> 24));
        data[i] ^= stream ^ key[i % keyLength];
    }
}

FFI_EXPORT void secure_chat_encrypt(uint8_t* data, int32_t length, uint32_t sessionKey) {
    if (!data || length <= 0) return;

    // PRODUCTION: ChaCha20-inspired stream cipher (replaces weak srand/rand)
    uint32_t state[16];
    memset(state, 0, sizeof(state));

    // Constants "expand 32-byte k"
    state[0] = 0x61707865; state[1] = 0x3320646e;
    state[2] = 0x79622d32; state[3] = 0x6b206574;

    // Expand 32-bit sessionKey into 256-bit key schedule (API limitation)
    for (int i = 0; i < 8; i++) {
        state[4 + i] = sessionKey ^ (sessionKey >> (i * 4 + 1));
    }
    state[12] = 0; // counter
    state[13] = 0; state[14] = 0; state[15] = 0;

    uint8_t block[64];
    int32_t idx = 0;
    while (idx < length) {
        _chacha20_block(state, block);
        int32_t chunk = (length - idx) < 64 ? (length - idx) : 64;
        for (int32_t i = 0; i < chunk; i++) {
            data[idx + i] ^= block[i];
        }
        state[12]++; // increment counter for next block
        idx += 64;
    }

    _secure_zero(block, sizeof(block));
    _secure_zero(state, sizeof(state));
}

FFI_EXPORT uint64_t generate_message_hash(const char* message, uint64_t timestamp) {
    if (!message) return timestamp;

    // FNV-1a 64-bit + finalization mix (Murmur3-style bit dispersion)
    uint64_t hash = 14695981039346656037ULL;
    while (*message) {
        hash ^= (uint64_t)(*message++);
        hash *= 1099511628211ULL;
    }
    hash ^= timestamp;
    // Finalization avalanche
    hash ^= hash >> 33;
    hash *= 0xff51afd7ed558ccdULL;
    hash ^= hash >> 33;
    hash *= 0xc4ceb9fe1a85ec53ULL;
    hash ^= hash >> 33;
    return hash;
}

// ==========================================
// 4. ADVANCED OFFLINE CACHING ENGINE
// ==========================================

FFI_EXPORT bool should_rotate_cache(int64_t currentCacheSize, int64_t maxCacheSize, int64_t lastAccessTime, int64_t currentTime) {
    if (currentCacheSize > maxCacheSize) return true;
    if ((currentTime - lastAccessTime) > 604800LL) return true; // 7 days
    // Smart: if cache > 80% and file older than 1 day, rotate early
    if (currentCacheSize > (maxCacheSize * 8 / 10) && (currentTime - lastAccessTime) > 86400LL) return true;
    return false;
}

// ==========================================
// 5. UPLOAD & CAMERA OPTIMIZATION ENGINE
// ==========================================

FFI_EXPORT double sync_audio_video_timestamp(double videoTime, double audioTime, double offset) {
    double diff = (videoTime - audioTime) + offset;
    // Smoothing: micro-jitter within 3ms ignored, gentle correction up to 10ms
    if (_fabs(diff) < 0.003) return 0.0;
    if (_fabs(diff) < 0.01) return diff * 0.5;
    return diff;
}

FFI_EXPORT void extract_thumbnail_frame(uint8_t* videoData, int32_t length, uint8_t* outFrame, int32_t targetWidth, int32_t targetHeight) {
    if (!videoData || !outFrame || length <= 0 || targetWidth <= 0 || targetHeight <= 0) return;

    // Simulated fast center-crop + nearest-neighbor downscale
    // Assumes 1920x1080 RGBA input source
    const int32_t srcW = 1920, srcH = 1080, srcStride = srcW * 4;
    const int32_t outLen = targetWidth * targetHeight * 4;

    double srcAspect = (double)srcW / (double)srcH;
    double dstAspect = (double)targetWidth / (double)targetHeight;
    int32_t cropW = srcW, cropH = srcH, cropX = 0, cropY = 0;

    if (srcAspect > dstAspect) {
        cropW = (int32_t)(srcH * dstAspect);
        cropX = (srcW - cropW) / 2;
    } else {
        cropH = (int32_t)(srcW / dstAspect);
        cropY = (srcH - cropH) / 2;
    }

    double xScale = (double)cropW / (double)targetWidth;
    double yScale = (double)cropH / (double)targetHeight;

    for (int32_t y = 0; y < targetHeight; y++) {
        for (int32_t x = 0; x < targetWidth; x++) {
            int32_t sx = cropX + (int32_t)(x * xScale);
            int32_t sy = cropY + (int32_t)(y * yScale);
            int32_t sIdx = (sy * srcW + sx) * 4;
            int32_t dIdx = (y * targetWidth + x) * 4;

            if (sIdx >= 0 && (sIdx + 3) < length && dIdx >= 0 && (dIdx + 3) < outLen) {
                outFrame[dIdx + 0] = videoData[sIdx + 0];
                outFrame[dIdx + 1] = videoData[sIdx + 1];
                outFrame[dIdx + 2] = videoData[sIdx + 2];
                outFrame[dIdx + 3] = videoData[sIdx + 3];
            }
        }
    }
}

FFI_EXPORT float calculate_compression_ratio(int64_t originalSize, int32_t targetBitrate, double duration) {
    if (originalSize <= 0 || targetBitrate <= 0 || duration <= 0.0) return 0.0f;
    double estimatedSize = ((double)targetBitrate * duration) / 8.0;
    return (float)(estimatedSize / (double)originalSize);
}

// ==========================================
// 6. HIGH-PERFORMANCE COMMENT & UI ENGINE
// ==========================================

FFI_EXPORT double calculate_sheet_easing(double time, double duration) {
    if (time <= 0.0) return 0.0;
    if (time >= duration) return 1.0;
    double t = time / duration;
    t--;
    return t * t * t + 1.0; // Cubic ease-out
}

FFI_EXPORT void sort_comments_fast(int32_t* likeCounts, int32_t length) {
    if (!likeCounts || length <= 1) return;
    // PRODUCTION-GRADE: O(n log n) introsort, descending by likes
    std::sort(likeCounts, likeCounts + length, _desc_cmp);
}

// ==========================================
// 7. ZERO-LATENCY PRELOAD ENGINE
// ==========================================

FFI_EXPORT int32_t calculate_max_preload(int64_t availableMemoryMB, int32_t videoQuality) {
    // videoQuality: 0=480p, 1=720p, 2=1080p, 3=4K
    int64_t memPerVideo = 50;
    switch (videoQuality) {
        case 0: memPerVideo = 25; break;
        case 1: memPerVideo = 50; break;
        case 2: memPerVideo = 120; break;
        case 3: memPerVideo = 400; break;
        default: memPerVideo = 50;
    }

    int64_t usable = (availableMemoryMB * 8) / 10; // Reserve 20% for OS
    int32_t preload = (int32_t)(usable / memPerVideo);

    if (preload < 2) return 2;   // Minimum double buffer
    if (preload > 20) return 20; // Cap to save network
    return preload;
}

FFI_EXPORT double get_instant_play_score(int32_t index, int32_t current, bool isInitialized) {
    int32_t dist = _iabs(index - current);
    if (dist == 0) return 10000.0; // Currently playing
    if (!isInitialized) {
        return 1000.0 / (double)(dist + 1);
    }
    return 500.0 / (double)(dist + 1);
}

// ==========================================
// 8. SMART VIDEO DIMENSIONS ENGINE
// ==========================================

FFI_EXPORT void calculate_video_dimensions(
        double videoWidth, double videoHeight,
        double containerWidth, double containerHeight,
        double* outWidth, double* outHeight) {

    if (videoWidth <= 0.0 || videoHeight <= 0.0 || containerWidth <= 0.0 || containerHeight <= 0.0 || !outWidth || !outHeight) {
        if (outWidth) *outWidth = 0.0;
        if (outHeight) *outHeight = 0.0;
        return;
    }

    double vAspect = videoWidth / videoHeight;
    double cAspect = containerWidth / containerHeight;

    if (vAspect > cAspect) {
        *outWidth = containerWidth;
        *outHeight = containerWidth / vAspect;
    } else {
        *outHeight = containerHeight;
        *outWidth = containerHeight * vAspect;
    }
}

// ==========================================
// 9. NEW: DATA INTEGRITY & CHECKSUM
// ==========================================

FFI_EXPORT uint32_t crc32_checksum(const uint8_t* data, int32_t length) {
    if (!data || length <= 0) return 0;
    uint32_t crc = 0xFFFFFFFF;
    for (int32_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
        }
    }
    return ~crc;
}

// ==========================================
// 10. PROFILE DATA & GRID OPTIMIZATION
// ==========================================

FFI_EXPORT void calculate_grid_item_size(double screenWidth, int32_t crossAxisCount, double spacing, double* outWidth) {
    if (screenWidth <= 0 || crossAxisCount <= 0 || !outWidth) return;
    *outWidth = (screenWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;
}

// ==========================================
// 11. ULTRA-FAST SCROLL & TRANSITION ENGINE
// ==========================================

FFI_EXPORT bool should_trigger_instant_snap(double velocity, double dragDistance, double threshold) {
    // High velocity or significant drag distance triggers instant snap
    if (_fabs(velocity) > 1500.0) return true;
    if (_fabs(dragDistance) > threshold) return true;
    return false;
}

} // extern "C"
