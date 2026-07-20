#ifndef VX_TOUCH_H
#define VX_TOUCH_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default")))
#endif

FFI_EXPORT void process_touch_event(int32_t pointerId, int32_t action,
                                    double x, double y, int64_t timestamp);
FFI_EXPORT double get_native_scroll_delta();
FFI_EXPORT double get_native_velocity();
FFI_EXPORT void reset_native_touch();
FFI_EXPORT bool should_trigger_haptic(double currentPixels, double viewportDimension);

/* NEW: Predict fling distance for snap-decision without animating frame-by-frame */
FFI_EXPORT double predict_fling_displacement(double deceleration);

#ifdef __cplusplus
}
#endif

#endif