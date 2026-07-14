#ifndef VX_FILTERS_H
#define VX_FILTERS_H

#include "../../core/vx_common.h"

extern "C" {

/**
 * Apply a high-performance filter to an RGBA buffer.
 * @param buffer Pointer to the RGBA data.
 * @param width Width of the image.
 * @param height Height of the image.
 * @param filterId 0=None, 1=Grayscale, 2=Sepia, 3=Invert, 4=Brightness Boost.
 */
FFI_EXPORT void apply_native_filter(uint8_t* buffer, int32_t width, int32_t height, int32_t filterId);

}

#endif // VX_FILTERS_H
