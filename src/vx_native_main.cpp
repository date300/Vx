#include "modules/physics/vx_physics.h"
#include "modules/security/vx_security.h"
#include "modules/video/vx_utils.h"
#include "modules/video/vx_video_player.h"
#include "modules/filters/vx_filters.h"

// Root entry point for NDK.
// Function implementations are now in their respective modules.

extern "C" {

FFI_EXPORT void* create_video_player() {
    return new VxVideoPlayer();
}

FFI_EXPORT void dispose_video_player(void* player) {
    delete static_cast<VxVideoPlayer*>(player);
}

FFI_EXPORT bool open_video(void* player, const char* url) {
    return static_cast<VxVideoPlayer*>(player)->open(url);
}

FFI_EXPORT void play_video(void* player) {
    static_cast<VxVideoPlayer*>(player)->play();
}

FFI_EXPORT void pause_video(void* player) {
    static_cast<VxVideoPlayer*>(player)->pause();
}

FFI_EXPORT void seek_video(void* player, int64_t timestampMs) {
    static_cast<VxVideoPlayer*>(player)->seek(timestampMs);
}

FFI_EXPORT bool get_video_frame(void* player, uint8_t* buffer, int width, int height) {
    return static_cast<VxVideoPlayer*>(player)->getNextFrame(buffer, width, height);
}

FFI_EXPORT int get_video_width(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getVideoWidth();
}

FFI_EXPORT int get_video_height(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getVideoHeight();
}

FFI_EXPORT double get_video_duration(void* player) {
    return static_cast<VxVideoPlayer*>(player)->getDuration();
}

FFI_EXPORT bool extract_video_thumbnail(void* player, const char* url, uint8_t* buffer, int width, int height, int64_t timeMs) {
    return static_cast<VxVideoPlayer*>(player)->extractThumbnail(url, buffer, width, height, timeMs);
}

}
