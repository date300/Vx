#include "modules/physics/vx_physics.h"
#include "modules/physics/vx_touch.h"
#include "modules/security/vx_security.h"
#include "modules/video/vx_utils.h"
#include "modules/video/vx_video_player.h"
#include "modules/filters/vx_filters.h"

#include <jni.h>
#include <pthread.h>
#include <atomic>
#include <cstdint>
#include <cstring>
#include <string>

extern "C" {
#include <libavcodec/jni.h>
}

/* ═══════════════════════════════════════════════════════════════
   COMPILER / PLATFORM ABSTRACTION
   ═══════════════════════════════════════════════════════════════ */
#if defined(__GNUC__) || defined(__clang__)
#define VX_LIKELY(x)    __builtin_expect(!!(x), 1)
#define VX_UNLIKELY(x)  __builtin_expect(!!(x), 0)
#define VX_INLINE       __attribute__((always_inline)) inline
#define VX_NOINLINE     __attribute__((noinline))
#else
#define VX_LIKELY(x)    (x)
#define VX_UNLIKELY(x)  (x)
#define VX_INLINE       inline
#define VX_NOINLINE
#endif

#if defined(__ANDROID__)
#include <android/log.h>
#define VX_LOGI(...) __android_log_print(ANDROID_LOG_INFO,  "VxNative", __VA_ARGS__)
#define VX_LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "VxNative", __VA_ARGS__)
#else
#define VX_LOGI(...) do {} while(0)
#define VX_LOGE(...) do {} while(0)
#endif

/* ═══════════════════════════════════════════════════════════════
   PLAYER HANDLE  (atomic ref-count + cached hot properties)
   ═══════════════════════════════════════════════════════════════ */
struct PlayerHandle {
    alignas(64) VxVideoPlayer* player;
    std::atomic<int32_t> refCount{1};

    // Cached hot properties (avoid locking player on every query)
    std::atomic<int> cachedWidth{0};
    std::atomic<int> cachedHeight{0};
    std::atomic<double> cachedDuration{0.0};
    std::atomic<bool> cacheValid{false};

    void invalidateCache() { cacheValid.store(false, std::memory_order_relaxed); }
    void ensureCache() {
        if (VX_LIKELY(cacheValid.load(std::memory_order_acquire))) return;
        cachedWidth.store(player->getVideoWidth(), std::memory_order_relaxed);
        cachedHeight.store(player->getVideoHeight(), std::memory_order_relaxed);
        cachedDuration.store(player->getDuration(), std::memory_order_relaxed);
        cacheValid.store(true, std::memory_order_release);
    }
};

static std::atomic<int32_t> g_instanceCounter{0};
static std::string g_cacheDir;
static pthread_mutex_t g_cacheMutex = PTHREAD_MUTEX_INITIALIZER;

/* ═══════════════════════════════════════════════════════════════
   INTERNAL HELPERS
   ═══════════════════════════════════════════════════════════════ */
VX_INLINE static PlayerHandle* acquire(void* opaque) {
    auto* h = static_cast<PlayerHandle*>(opaque);
    if (VX_UNLIKELY(!h)) return nullptr;
    h->refCount.fetch_add(1, std::memory_order_relaxed);
    return h;
}

VX_INLINE static void release(PlayerHandle* h) {
    if (VX_UNLIKELY(!h)) return;
    if (h->refCount.fetch_sub(1, std::memory_order_acq_rel) == 1) {
        delete h->player;
        delete h;
        g_instanceCounter.fetch_sub(1, std::memory_order_relaxed);
    }
}

VX_INLINE static VxVideoPlayer* ptr(PlayerHandle* h) {
    return VX_LIKELY(h) ? h->player : nullptr;
}

/* ═══════════════════════════════════════════════════════════════
   JNI LIFECYCLE
   ═══════════════════════════════════════════════════════════════ */
static JavaVM* g_vm = nullptr;

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/) {
g_vm = vm;
if (VX_UNLIKELY(av_jni_set_java_vm(vm, nullptr) < 0)) {
VX_LOGE("Failed to set JavaVM for FFmpeg");
}
VX_LOGI("VxNative loaded, JNI_VERSION_1_6");
return JNI_VERSION_1_6;
}

extern "C" JNIEXPORT void JNI_OnUnload(JavaVM* vm, void* /*reserved*/) {
    VX_LOGI("VxNative unloading, remaining players: %d",
            g_instanceCounter.load(std::memory_order_relaxed));
    g_vm = nullptr;
}

/* ═══════════════════════════════════════════════════════════════
   VIDEO PLAYER API
   ═══════════════════════════════════════════════════════════════ */
extern "C" {

FFI_EXPORT void set_cache_directory(const char* path) {
    if (VX_UNLIKELY(!path)) return;
    pthread_mutex_lock(&g_cacheMutex);
    g_cacheDir.assign(path);
    pthread_mutex_unlock(&g_cacheMutex);
    VxVideoPlayer::setCacheDirectory(path);
}

FFI_EXPORT void* create_video_player() {
    auto* h = new PlayerHandle();
    h->player = new VxVideoPlayer();
    g_instanceCounter.fetch_add(1, std::memory_order_relaxed);
    return h;
}

FFI_EXPORT void dispose_video_player(void* opaque) {
    auto* h = acquire(opaque);
    if (VX_UNLIKELY(!h)) return;
    release(h); // drop user's ref
    release(h); // drop create()'s ref  → delete when 0
}

FFI_EXPORT bool open_video(void* opaque, const char* url) {
    auto* h = acquire(opaque);
    if (VX_UNLIKELY(!h || !url)) { release(h); return false; }

    bool ok = h->player->open(url);
    if (ok) h->invalidateCache();
    release(h);
    return ok;
}

FFI_EXPORT void play_video(void* opaque) {
    auto* h = acquire(opaque);
    if (VX_LIKELY(h)) h->player->play();
    release(h);
}

FFI_EXPORT void pause_video(void* opaque) {
    auto* h = acquire(opaque);
    if (VX_LIKELY(h)) h->player->pause();
    release(h);
}

FFI_EXPORT void seek_video(void* opaque, int64_t timestampMs) {
    auto* h = acquire(opaque);
    if (VX_LIKELY(h)) h->player->seek(timestampMs);
    release(h);
}

/* ── Frame delivery: zero-copy when buffer is provided by Dart ── */
FFI_EXPORT bool get_video_frame(void* opaque, uint8_t* buffer, int width, int height) {
    auto* h = acquire(opaque);
    if (VX_UNLIKELY(!h || !buffer || width <= 0 || height <= 0)) {
        release(h);
        return false;
    }
    bool ok = h->player->getNextFrame(buffer, width, height);
    release(h);
    return ok;
}

/* ── Hot getters: lock-free cached path ── */
FFI_EXPORT int get_video_width(void* opaque) {
    auto* h = acquire(opaque);
    int w = 0;
    if (VX_LIKELY(h)) {
        h->ensureCache();
        w = h->cachedWidth.load(std::memory_order_relaxed);
    }
    release(h);
    return w;
}

FFI_EXPORT int get_video_height(void* opaque) {
    auto* h = acquire(opaque);
    int hgt = 0;
    if (VX_LIKELY(h)) {
        h->ensureCache();
        hgt = h->cachedHeight.load(std::memory_order_relaxed);
    }
    release(h);
    return hgt;
}

FFI_EXPORT double get_video_duration(void* opaque) {
    auto* h = acquire(opaque);
    double d = 0.0;
    if (VX_LIKELY(h)) {
        h->ensureCache();
        d = h->cachedDuration.load(std::memory_order_relaxed);
    }
    release(h);
    return d;
}

/* ── NEW: Batch state query (one FFI call, 3 values) ── */
FFI_EXPORT void get_video_state(void* opaque, int* outWidth, int* outHeight, double* outDuration) {
    auto* h = acquire(opaque);
    if (VX_UNLIKELY(!h || !outWidth || !outHeight || !outDuration)) {
        release(h);
        return;
    }
    h->ensureCache();
    *outWidth    = h->cachedWidth.load(std::memory_order_relaxed);
    *outHeight   = h->cachedHeight.load(std::memory_order_relaxed);
    *outDuration = h->cachedDuration.load(std::memory_order_relaxed);
    release(h);
}

FFI_EXPORT bool extract_video_thumbnail(void* opaque, const char* url,
                                        uint8_t* buffer, int width, int height,
                                        int64_t timeMs) {
    auto* h = acquire(opaque);
    if (VX_UNLIKELY(!h || !url || !buffer)) { release(h); return false; }
    bool ok = h->player->extractThumbnail(url, buffer, width, height, timeMs);
    release(h);
    return ok;
}

/* ═══════════════════════════════════════════════════════════════
   THREADING & POWER
   ═══════════════════════════════════════════════════════════════ */

#if defined(__ANDROID__)
#include <sys/resource.h>
#include <sys/syscall.h>
#include <unistd.h>

FFI_EXPORT void set_thread_priority(int32_t priority) {
    // priority: -20 (high) .. 19 (idle).  We map to Android nice.
    int nice = priority;
    if (nice < -20) nice = -20;
    if (nice > 19)  nice = 19;

    pid_t tid = syscall(SYS_gettid);
    if (setpriority(PRIO_PROCESS, tid, nice) != 0) {
        VX_LOGE("setpriority failed for tid %d", (int)tid);
    }
}

FFI_EXPORT void request_turbo_boost(bool enable) {
    // Android: request SCHED_FIFO for the calling thread when enable=true
    if (enable) {
        struct sched_param param{};
        param.sched_priority = 1; // lowest FIFO
        pthread_setschedparam(pthread_self(), SCHED_FIFO, &param);
    } else {
        struct sched_param param{};
        pthread_setschedparam(pthread_self(), SCHED_OTHER, &param);
    }
}
#else
FFI_EXPORT void set_thread_priority(int32_t /*priority*/) {}
FFI_EXPORT void request_turbo_boost(bool /*enable*/) {}
#endif

} // extern "C"