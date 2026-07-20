#include "vx_touch.h"
#include <array>
#include <cmath>

/* ── Compiler hints ── */
#if defined(__GNUC__) || defined(__clang__)
#define VX_LIKELY(x)    __builtin_expect(!!(x), 1)
#define VX_UNLIKELY(x)  __builtin_expect(!!(x), 0)
#define VX_INLINE       __attribute__((always_inline)) inline
#else
#define VX_LIKELY(x)    (x)
#define VX_UNLIKELY(x)  (x)
#define VX_INLINE       inline
#endif

/* ── Action codes ── */
enum TouchAction : int32_t {
    ACTION_DOWN   = 0,
    ACTION_MOVE   = 1,
    ACTION_UP     = 2,
    ACTION_CANCEL = 3,
};

/* ── Fixed-size circular buffer (zero heap, zero memmove) ── */
struct TouchPoint {
    double x;
    double y;
    int64_t timestamp; // ms
};

struct TouchState {
    int32_t  pointerId   = -1;
    bool     isActive    = false;
    double   lastDeltaY  = 0.0;

    // Power-of-2 → bitmask indexing, no modulo/divide
    static constexpr uint32_t kCapacity = 16;
    static constexpr uint32_t kMask     = kCapacity - 1;

    alignas(64) std::array<TouchPoint, kCapacity> history;
    uint32_t head  = 0;  // next write position
    uint32_t count = 0;  // valid items
};

static TouchState g_state;

/* ── Circular buffer helpers ── */
VX_INLINE static void push_point(double x, double y, int64_t ts) {
    uint32_t idx = g_state.head & TouchState::kMask;
    g_state.history[idx] = {x, y, ts};
    g_state.head = (g_state.head + 1) & TouchState::kMask;
    if (VX_LIKELY(g_state.count < TouchState::kCapacity))
        ++g_state.count;
}

// offset 0 = most recent, 1 = second most recent, ...
VX_INLINE static const TouchPoint& point_from_end(uint32_t offset) {
    uint32_t idx = (g_state.head - 1 - offset) & TouchState::kMask;
    return g_state.history[idx];
}

/* ── Velocity: weighted exponential on recent intervals ──
   (first->last)/dt is noisy; this matches Android/iOS fling physics. */
VX_INLINE static double estimate_velocity_y() {
    uint32_t n = g_state.count;
    if (VX_UNLIKELY(n < 2)) return 0.0;

    // Look at last 5 intervals (6 points max)
    const uint32_t maxIntervals = 5;
    uint32_t intervals = (n - 1 < maxIntervals) ? (n - 1) : maxIntervals;

    double velSum = 0.0;
    double wSum   = 0.0;
    double w      = 1.0;
    const double wDecay = 0.5; // recent interval counts 2× more

    for (uint32_t i = 0; i < intervals; ++i) {
        const TouchPoint& curr = point_from_end(i);
        const TouchPoint& prev = point_from_end(i + 1);

        int64_t dtMs = curr.timestamp - prev.timestamp;
        if (VX_UNLIKELY(dtMs <= 0)) continue;

        double dtSec = static_cast<double>(dtMs) * 0.001; // ms → s
        double v = (curr.y - prev.y) / dtSec;

        velSum += w * v;
        wSum   += w;
        w *= wDecay;
    }
    return VX_UNLIKELY(wSum == 0.0) ? 0.0 : (velSum / wSum);
}

/* ═══════════════════════════════════════════════════════
   PUBLIC API
   ═══════════════════════════════════════════════════════ */
extern "C" {

FFI_EXPORT void process_touch_event(int32_t pointerId, int32_t action,
                                    double x, double y, int64_t timestamp) {
    if (VX_LIKELY(action == ACTION_MOVE)) {
        if (VX_UNLIKELY(!g_state.isActive || g_state.pointerId != pointerId))
            return;

        if (VX_LIKELY(g_state.count > 0)) {
            const TouchPoint& last = point_from_end(0);
            // Accumulate delta to ensure we don't lose movement between Dart frames
            g_state.lastDeltaY += (y - last.y);
        }
        push_point(x, y, timestamp);
    }
    else if (action == ACTION_DOWN) {
        g_state.pointerId = pointerId;
        g_state.isActive  = true;
        g_state.head      = 0;
        g_state.count     = 0;
        g_state.lastDeltaY = 0.0;
        push_point(x, y, timestamp);
    }
    else { // UP or CANCEL
        g_state.isActive   = false;
        g_state.lastDeltaY = 0.0;
    }
}

FFI_EXPORT double get_native_scroll_delta() {
    double d = g_state.lastDeltaY;
    g_state.lastDeltaY = 0.0;
    return d;
}

FFI_EXPORT double get_native_velocity() {
    return estimate_velocity_y();
}

FFI_EXPORT void reset_native_touch() {
    g_state.isActive   = false;
    g_state.pointerId  = -1;
    g_state.head       = 0;
    g_state.count      = 0;
    g_state.lastDeltaY = 0.0;
}

static double g_lastHapticPos = -1.0;

FFI_EXPORT bool should_trigger_haptic(double currentPixels, double viewportDimension) {
    if (viewportDimension <= 0) return false;

    // Only trigger haptic when we cross the "Snap Boundary" (halfway through a page)
    double currentPageFraction = currentPixels / viewportDimension;
    double snapBoundary = std::floor(currentPageFraction + 0.5);

    // Check if we just crossed a new snap boundary
    if (std::abs(currentPageFraction - snapBoundary) < 0.05 && snapBoundary != g_lastHapticPos) {
        g_lastHapticPos = snapBoundary;
        return true;
    }
    return false;
}

/* NEW: Predict where the fling will end so you can snap immediately
   instead of simulating every frame.
   deceleration = px/s² (e.g. 3000.0 for a quick stop)               */
FFI_EXPORT double predict_fling_displacement(double deceleration) {
    if (VX_UNLIKELY(deceleration <= 0.0)) return 0.0;

    double v = estimate_velocity_y();
    if (VX_UNLIKELY(std::fabs(v) < 10.0)) return 0.0; // below noise floor

    double sign = (v < 0.0) ? -1.0 : 1.0;
    return sign * (v * v) / (2.0 * deceleration);
}

} // extern "C"