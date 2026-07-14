#ifndef AVUTIL_HWCONTEXT_H
#define AVUTIL_HWCONTEXT_H

#include "avutil.h"
#include "pixfmt.h"

enum AVHWDeviceType {
    AV_HWDEVICE_TYPE_NONE,
    AV_HWDEVICE_TYPE_VDPAU,
    AV_HWDEVICE_TYPE_CUDA,
    AV_HWDEVICE_TYPE_VAAPI,
    AV_HWDEVICE_TYPE_DXVA2,
    AV_HWDEVICE_TYPE_QSV,
    AV_HWDEVICE_TYPE_VIDEOTOOLBOX,
    AV_HWDEVICE_TYPE_D3D11VA,
    AV_HWDEVICE_TYPE_DRM,
    AV_HWDEVICE_TYPE_OPENCL,
    AV_HWDEVICE_TYPE_MEDIACODEC,
    AV_HWDEVICE_TYPE_VULKAN,
};

typedef struct AVHWDeviceContext {
    void *hwctx;
    // ... other fields stubbed
} AVHWDeviceContext;

typedef struct AVBufferRef AVBufferRef;

AVHWDeviceType av_hwdevice_find_type_by_name(const char *name);
int av_hwdevice_ctx_create(AVBufferRef **device_ctx, enum AVHWDeviceType type,
                           const char *device, void *opts, int flags);
int av_hwframe_transfer_data(struct AVFrame *dst, const struct AVFrame *src, int flags);

#endif /* AVUTIL_HWCONTEXT_H */
