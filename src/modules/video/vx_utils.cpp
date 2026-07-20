#include "vx_utils.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <android/log.h>

extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/timestamp.h>
}

#define LOG_TAG "VxNativeUtils"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

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
    if (preload > 10) return 10; // Balanced limit for performance vs data
    return preload;
}

FFI_EXPORT void calculate_video_dimensions(double videoWidth, double videoHeight, double containerWidth, double containerHeight, double* outWidth, double* outHeight) {
    if (containerWidth <= 0.0 || containerHeight <= 0.0 || !outWidth || !outHeight) return;

    // Use actual video aspect ratio if valid, otherwise fallback to 9:16
    double targetAspect = (videoWidth > 0 && videoHeight > 0)
        ? (videoWidth / videoHeight)
        : (9.0 / 16.0);

    double screenAspect = containerWidth / containerHeight;

    if (screenAspect > targetAspect) {
        // Container is wider than video - fit to height
        *outHeight = containerHeight;
        *outWidth = containerHeight * targetAspect;
    } else {
        // Container is taller than video - fit to width
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

FFI_EXPORT int32_t trim_video(const char* inputPath, const char* outputPath, double startTime, double duration) {
    AVFormatContext *ifmt_ctx = nullptr, *ofmt_ctx = nullptr;
    AVPacket pkt;
    int ret, i;
    int stream_index = 0;
    int *stream_mapping = nullptr;
    int stream_mapping_size = 0;

    if ((ret = avformat_open_input(&ifmt_ctx, inputPath, nullptr, nullptr)) < 0) {
        LOGE("Could not open input file '%s'", inputPath);
        return ret;
    }

    if ((ret = avformat_find_stream_info(ifmt_ctx, nullptr)) < 0) {
        LOGE("Failed to retrieve input stream information");
        avformat_close_input(&ifmt_ctx);
        return ret;
    }

    avformat_alloc_output_context2(&ofmt_ctx, nullptr, nullptr, outputPath);
    if (!ofmt_ctx) {
        LOGE("Could not create output context");
        avformat_close_input(&ifmt_ctx);
        return AVERROR_UNKNOWN;
    }

    stream_mapping_size = ifmt_ctx->nb_streams;
    stream_mapping = (int*)av_calloc(stream_mapping_size, sizeof(*stream_mapping));
    if (!stream_mapping) {
        ret = AVERROR(ENOMEM);
        goto end;
    }

    for (i = 0; i < ifmt_ctx->nb_streams; i++) {
        AVStream *out_stream;
        AVStream *in_stream = ifmt_ctx->streams[i];
        AVCodecParameters *in_codecpar = in_stream->codecpar;

        if (in_codecpar->codec_type != AVMEDIA_TYPE_VIDEO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_AUDIO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_SUBTITLE) {
            stream_mapping[i] = -1;
            continue;
        }

        stream_mapping[i] = stream_index++;

        out_stream = avformat_new_stream(ofmt_ctx, nullptr);
        if (!out_stream) {
            LOGE("Failed allocating output stream");
            ret = AVERROR_UNKNOWN;
            goto end;
        }

        ret = avcodec_parameters_copy(out_stream->codecpar, in_codecpar);
        if (ret < 0) {
            LOGE("Failed to copy codec parameters");
            goto end;
        }
        out_stream->codecpar->codec_tag = 0;
    }

    if (!(ofmt_ctx->oformat->flags & AVFMT_NOFILE)) {
        ret = avio_open(&ofmt_ctx->pb, outputPath, AVIO_FLAG_WRITE);
        if (ret < 0) {
            LOGE("Could not open output file '%s'", outputPath);
            goto end;
        }
    }

    ret = avformat_write_header(ofmt_ctx, nullptr);
    if (ret < 0) {
        LOGE("Error occurred when opening output file");
        goto end;
    }

    ret = av_seek_frame(ifmt_ctx, -1, startTime * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
    if (ret < 0) {
        LOGE("Error seeking");
        goto end;
    }

    while (1) {
        AVStream *in_stream, *out_stream;

        ret = av_read_frame(ifmt_ctx, &pkt);
        if (ret < 0) break;

        in_stream  = ifmt_ctx->streams[pkt.stream_index];
        if (pkt.stream_index >= stream_mapping_size ||
            stream_mapping[pkt.stream_index] < 0) {
            av_packet_unref(&pkt);
            continue;
        }

        pkt.stream_index = stream_mapping[pkt.stream_index];
        out_stream = ofmt_ctx->streams[pkt.stream_index];

        if (av_q2d(in_stream->time_base) * pkt.pts > startTime + duration) {
            av_packet_unref(&pkt);
            break;
        }

        pkt.pts = av_rescale_q(pkt.pts - av_rescale_q(startTime * AV_TIME_BASE, AV_TIME_BASE_Q, in_stream->time_base), in_stream->time_base, out_stream->time_base);
        pkt.dts = av_rescale_q(pkt.dts - av_rescale_q(startTime * AV_TIME_BASE, AV_TIME_BASE_Q, in_stream->time_base), in_stream->time_base, out_stream->time_base);
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;

        ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
        if (ret < 0) {
            LOGE("Error muxing packet");
            break;
        }
        av_packet_unref(&pkt);
    }

    av_write_trailer(ofmt_ctx);
end:
    avformat_close_input(&ifmt_ctx);

    if (ofmt_ctx && !(ofmt_ctx->oformat->flags & AVFMT_NOFILE))
        avio_closep(&ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);

    av_freep(&stream_mapping);

    if (ret < 0 && ret != AVERROR_EOF) {
        LOGE("Error occurred: %s", av_err2str(ret));
        return ret;
    }

    return 0;
}

}
