#ifndef AVCODEC_AVCODEC_H
#define AVCODEC_AVCODEC_H

#include "libavutil/avutil.h"
#include "libavutil/pixfmt.h"

typedef struct AVCodecParameters {
    enum AVMediaType codec_type;
    uint32_t codec_id;
    int width;
    int height;
} AVCodecParameters;

typedef struct AVCodec {
    const char *name;
    uint32_t id;
} AVCodec;

typedef struct AVCodecContext {
    int width;
    int height;
    struct AVBufferRef *hw_device_ctx;
    enum AVPixelFormat format;
} AVCodecContext;

typedef struct AVFrame {
    uint8_t *data[8];
    int linesize[8];
    int width, height;
    int format;
    int64_t pts;
} AVFrame;

typedef struct AVPacket {
    uint8_t *data;
    int size;
    int stream_index;
    int64_t pts;
    int64_t dts;
} AVPacket;

void av_packet_unref(AVPacket *pkt);
void av_packet_free(AVPacket **pkt);
AVPacket *av_packet_alloc(void);
AVPacket *av_packet_clone(const AVPacket *src);

AVFrame *av_frame_alloc(void);
void av_frame_free(AVFrame **frame);
AVFrame *av_frame_clone(const AVFrame *src);

const AVCodec *avcodec_find_decoder(uint32_t id);
AVCodecContext *avcodec_alloc_context3(const AVCodec *codec);
void avcodec_free_context(AVCodecContext **avctx);
int avcodec_parameters_to_context(AVCodecContext *codec, const AVCodecParameters *par);
int avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, void **options);
int avcodec_send_packet(AVCodecContext *avctx, const AVPacket *avpkt);
int avcodec_receive_frame(AVCodecContext *avctx, AVFrame *frame);
void avcodec_flush_buffers(AVCodecContext *avctx);

#endif /* AVCODEC_AVCODEC_H */
