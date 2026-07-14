cmake_minimum_required(VERSION 3.10)

project(vx_native VERSION 1.0.0 LANGUAGES CXX)

# FFmpeg setup
set(FFMPEG_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../android/app/libs)
set(FFMPEG_INCLUDE_DIR ${FFMPEG_LIBS_DIR}/include)

include_directories(${FFMPEG_INCLUDE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Merged FFmpeg library
add_library(ffmpeg SHARED IMPORTED)
set_target_properties(ffmpeg PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/${ANDROID_ABI}/libffmpeg.so)

add_library(vx_native SHARED
  vx_native_main.cpp
  modules/physics/vx_physics.cpp
  modules/security/vx_security.cpp
  modules/video/vx_utils.cpp
  modules/video/vx_video_player.cpp
  modules/filters/vx_filters.cpp
)

set_target_properties(vx_native PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
)

target_link_libraries(vx_native
  ffmpeg
  log
  android
)
