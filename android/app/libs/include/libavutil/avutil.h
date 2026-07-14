#ifndef AVUTIL_AVUTIL_H
#define AVUTIL_AVUTIL_H

#include <stdint.h>
#include <stddef.h>

/**
 * @defgroup lavu_media AVMEDIA_TYPE
 * @{
 */
enum AVMediaType {
    AVMEDIA_TYPE_UNKNOWN = -1,  ///< Usually treated as AVMEDIA_TYPE_DATA
    AVMEDIA_TYPE_VIDEO,
    AVMEDIA_TYPE_AUDIO,
    AVMEDIA_TYPE_DATA,          ///< Opaque data information usually continuous
    AVMEDIA_TYPE_SUBTITLE,
    AVMEDIA_TYPE_ATTACHMENT,    ///< Opaque data information usually sparse
    AVMEDIA_TYPE_NB
};
/**
 * @}
 */

typedef struct AVRational {
    int num; ///< Numerator
    int den; ///< Denominator
} AVRational;

static inline double av_q2d(AVRational a) {
    if (a.den == 0) return 0;
    return a.num / (double)a.den;
}

#define AV_TIME_BASE            1000000

#define AVERROR(e) (-(e))
#define AVERROR_EOF             AVERROR(0xDEADBEEF)
#define EAGAIN                  11

typedef struct AVBufferRef AVBufferRef;

AVBufferRef *av_buffer_ref(AVBufferRef *buf);
void av_buffer_unref(AVBufferRef **buf);

int64_t av_rescale_q(int64_t a, AVRational bq, AVRational cq);

#endif /* AVUTIL_AVUTIL_H */
