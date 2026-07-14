#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// This file provides dummy implementations of FFmpeg functions to satisfy the linker
// since the actual .so files provided are 0-byte placeholders.

extern "C" {

// libavutil
typedef struct AVRational { int num; int den; } AVRational;
typedef struct AVBufferRef AVBufferRef;
typedef struct AVFrame { uint8_t *data[8]; int linesize[8]; int width, height; int format; int64_t pts; } AVFrame;

int64_t av_gettime(void) { return 0; }
int64_t av_gettime_relative(void) { return 0; }
int av_usleep(unsigned usec) { return 0; }

AVBufferRef *av_buffer_ref(AVBufferRef *buf) { return nullptr; }
void av_buffer_unref(AVBufferRef **buf) { if (buf) *buf = nullptr; }

int64_t av_rescale_q(int64_t a, AVRational bq, AVRational cq) { return a; }

AVFrame *av_frame_alloc(void) { return (AVFrame*)calloc(1, sizeof(AVFrame)); }
void av_frame_free(AVFrame **frame) { if (frame && *frame) { free(*frame); *frame = nullptr; } }
AVFrame *av_frame_clone(const AVFrame *src) { return nullptr; }

int av_hwdevice_ctx_create(AVBufferRef **device_ctx, int type, const char *device, void *opts, int flags) { return -1; }
int av_hwdevice_find_type_by_name(const char *name) { return 0; }
int av_hwframe_transfer_data(AVFrame *dst, const AVFrame *src, int flags) { return -1; }

// libavcodec
typedef struct AVPacket { uint8_t *data; int size; int stream_index; int64_t pts; int64_t dts; } AVPacket;

void av_packet_unref(AVPacket *pkt) {}
void av_packet_free(AVPacket **pkt) { if (pkt && *pkt) { free(*pkt); *pkt = nullptr; } }
AVPacket *av_packet_alloc(void) { return (AVPacket*)calloc(1, sizeof(AVPacket)); }
AVPacket *av_packet_clone(const AVPacket *src) { return nullptr; }

void* avcodec_find_decoder(uint32_t id) { return nullptr; }
void* avcodec_alloc_context3(void *codec) { return malloc(1024); } // Dummy size
void avcodec_free_context(void **avctx) { if (avctx && *avctx) { free(*avctx); *avctx = nullptr; } }
int avcodec_parameters_to_context(void *codec, void *par) { return 0; }
int avcodec_open2(void *avctx, void *codec, void **options) { return -1; }
int avcodec_send_packet(void *avctx, const AVPacket *avpkt) { return -1; }
int avcodec_receive_frame(void *avctx, AVFrame *frame) { return -1; }
void avcodec_flush_buffers(void *avctx) {}

// libavformat
int avformat_network_init(void) { return 0; }
int avformat_open_input(void **ps, const char *url, void *fmt, void **options) { return -1; }
int avformat_find_stream_info(void *ic, void **options) { return -1; }
void avformat_close_input(void **s) { if (s && *s) *s = nullptr; }
int av_read_frame(void *s, AVPacket *pkt) { return -1; }
int av_seek_frame(void *s, int stream_index, int64_t timestamp, int flags) { return -1; }

int av_strerror(int errnum, char *errbuf, size_t errbuf_size) {
    strncpy(errbuf, "FFmpeg Stub Error", errbuf_size);
    return 0;
}

// libswscale
void* sws_getContext(int srcW, int srcH, int srcFormat, int dstW, int dstH, int dstFormat, int flags, void *srcFilter, void *dstFilter, const double *param) { return nullptr; }
int sws_scale(void *c, const uint8_t *const srcSlice[], const int srcStride[], int srcSliceY, int srcSliceH, uint8_t *const dst[], const int dstStride[]) { return 0; }
void sws_freeContext(void *swsContext) {}

}
