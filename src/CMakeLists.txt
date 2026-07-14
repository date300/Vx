cmake_minimum_required(VERSION 3.10)

project(vx_native VERSION 1.0.0 LANGUAGES CXX)

# FFmpeg setup
set(FFMPEG_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../android/app/libs)
set(FFMPEG_INCLUDE_DIR ${FFMPEG_LIBS_DIR}/include)

include_directories(${FFMPEG_INCLUDE_DIR})

# Note: We are not linking against the external FFmpeg .so files
# because they are currently 0-byte placeholders.
# Instead, we use ffmpeg_stubs.cpp to satisfy the linker.

add_library(vx_native SHARED
  vx_native.cpp
  vx_video_player.cpp
  ffmpeg_stubs.cpp
)

set_target_properties(vx_native PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
)

target_link_libraries(vx_native
  log
  android
)
