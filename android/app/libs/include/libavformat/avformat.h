#ifndef AVFORMAT_AVFORMAT_H
#define AVFORMAT_AVFORMAT_H

#include "libavcodec/avcodec.h"

typedef struct AVStream {
    int index;
    AVCodecParameters *codecpar;
    AVRational time_base;
    AVRational avg_frame_rate;
    AVRational r_frame_rate;
} AVStream;

typedef struct AVFormatContext {
    unsigned int nb_streams;
    AVStream **streams;
    int64_t duration;
} AVFormatContext;

int avformat_network_init(void);
int avformat_open_input(AVFormatContext **ps, const char *url, void *fmt, void **options);
int avformat_find_stream_info(AVFormatContext *ic, void **options);
void avformat_close_input(AVFormatContext **s);
int av_read_frame(AVFormatContext *s, AVPacket *pkt);
int av_seek_frame(AVFormatContext *s, int stream_index, int64_t timestamp, int flags);
#define AVSEEK_FLAG_BACKWARD 1

const char *av_err2str(int errnum);
int av_strerror(int errnum, char *errbuf, size_t errbuf_size);

#endif /* AVFORMAT_AVFORMAT_H */
