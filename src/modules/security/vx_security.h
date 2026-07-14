#ifndef VX_SECURITY_H
#define VX_SECURITY_H

#include "../../core/vx_common.h"

extern "C" {
FFI_EXPORT void native_encrypt_data(uint8_t* data, int32_t length, uint8_t* key, int32_t keyLength);
FFI_EXPORT void secure_chat_encrypt(uint8_t* data, int32_t length, uint32_t sessionKey);
FFI_EXPORT uint64_t generate_message_hash(const char* message, uint64_t timestamp);
FFI_EXPORT uint32_t crc32_checksum(const uint8_t* data, int32_t length);
}

#endif // VX_SECURITY_H
