#ifndef AVUTIL_IMGUTILS_H
#define AVUTIL_IMGUTILS_H

#include "avutil.h"
#include "pixfmt.h"

int av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4],
                         const uint8_t *src, enum AVPixelFormat pix_fmt,
                         int width, int height, int align);

int av_image_get_buffer_size(enum AVPixelFormat pix_fmt, int width, int height, int align);

#endif /* AVUTIL_IMGUTILS_H */
