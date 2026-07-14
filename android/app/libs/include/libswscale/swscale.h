#ifndef SWSCALE_SWSCALE_H
#define SWSCALE_SWSCALE_H

#include <stdint.h>
#include "libavutil/pixfmt.h"

struct SwsContext;

#define SWS_FAST_BILINEAR 1
#define SWS_LANCZOS       2

struct SwsContext *sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat,
                                  int dstW, int dstH, enum AVPixelFormat dstFormat,
                                  int flags, void *srcFilter,
                                  void *dstFilter, const double *param);

int sws_scale(struct SwsContext *c, const uint8_t *const srcSlice[],
              const int srcStride[], int srcSliceY, int srcSliceH,
              uint8_t *const dst[], const int dstStride[]);

void sws_freeContext(struct SwsContext *swsContext);

#endif /* SWSCALE_SWSCALE_H */
