#include "vx_utils.h"
#include <math.h>
#include <stdlib.h>

extern "C" {

FFI_EXPORT int32_t calculate_buffer_priority(double scrollVelocity, int32_t videoIndex, int32_t currentIndex) {
    int32_t distance = abs(videoIndex - currentIndex);
    if (scrollVelocity > 500.0 && videoIndex > currentIndex) {
        if (distance == 0) return 1000;
        if (distance <= 2) return 500;
        return 100;
    }
    if (distance == 0) return 1000;
    if (distance == 1) return 500;
    return (int32_t)(100.0 / (double)(distance + 1));
}

FFI_EXPORT void native_optimize_memory() {
    // Platform specific memory cleanup logic
}

FFI_EXPORT int32_t calculate_max_preload(int64_t availableMemoryMB, int32_t videoQuality) {
    int64_t memPerVideo = 50;
    switch (videoQuality) {
        case 0: memPerVideo = 25; break;
        case 1: memPerVideo = 50; break;
        case 2: memPerVideo = 120; break;
        default: memPerVideo = 50;
    }
    int64_t usable = (availableMemoryMB * 8) / 10;
    int32_t preload = (int32_t)(usable / memPerVideo);
    if (preload < 2) return 2;
    if (preload > 20) return 20;
    return preload;
}

FFI_EXPORT void calculate_video_dimensions(double videoWidth, double videoHeight, double containerWidth, double containerHeight, double* outWidth, double* outHeight) {
    if (containerWidth <= 0.0 || containerHeight <= 0.0 || !outWidth || !outHeight) return;

    // Industry standard 9:16 aspect ratio (TikTok/Shorts)
    const double targetAspect = 9.0 / 16.0;
    double screenAspect = containerWidth / containerHeight;

    if (screenAspect > targetAspect) {
        // Container is wider than 9:16 (e.g., tablet) - fit to height
        *outHeight = containerHeight;
        *outWidth = containerHeight * targetAspect;
    } else {
        // Container is taller than 9:16 (modern phones) - fit to width
        *outWidth = containerWidth;
        *outHeight = containerWidth / targetAspect;
    }
}

FFI_EXPORT void calculate_grid_item_size(double screenWidth, int32_t crossAxisCount, double spacing, double* outWidth) {
    if (screenWidth <= 0 || crossAxisCount <= 0 || !outWidth) return;
    *outWidth = (screenWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;
}

FFI_EXPORT bool should_trigger_instant_snap(double velocity, double dragDistance, double threshold) {
    return (abs(velocity) > 1500.0 || abs(dragDistance) > threshold);
}

FFI_EXPORT double calculate_sheet_easing(double time, double duration) {
    if (time <= 0.0) return 0.0;
    if (time >= duration) return 1.0;
    double t = time / duration;
    t--;
    return t * t * t + 1.0;
}

}
