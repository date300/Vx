#ifndef VX_COMMON_H
#define VX_COMMON_H

#include <stdint.h>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#endif // VX_COMMON_H
