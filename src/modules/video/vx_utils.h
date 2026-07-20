#ifndef VX_VIDEO_UTILS_H
#define VX_VIDEO_UTILS_H

#include "../../core/vx_common.h"

extern "C" {
FFI_EXPORT int32_t calculate_buffer_priority(double scrollVelocity, int32_t videoIndex, int32_t currentIndex);
FFI_EXPORT void native_optimize_memory();
FFI_EXPORT int32_t calculate_max_preload(int64_t availableMemoryMB, int32_t videoQuality);
FFI_EXPORT void calculate_video_dimensions(double videoWidth, double videoHeight, double containerWidth, double containerHeight, double* outWidth, double* outHeight);
FFI_EXPORT void calculate_grid_item_size(double screenWidth, int32_t crossAxisCount, double spacing, double* outWidth);
FFI_EXPORT bool should_trigger_instant_snap(double velocity, double dragDistance, double threshold);
FFI_EXPORT double calculate_sheet_easing(double time, double duration);
FFI_EXPORT int32_t trim_video(const char* inputPath, const char* outputPath, double startTime, double duration);
}

#endif // VX_VIDEO_UTILS_H
