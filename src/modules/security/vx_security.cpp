#include "vx_security.h"
#include <string.h>

static inline uint64_t _xorshift64star(uint64_t* state) {
    uint64_t x = *state;
    x ^= x >> 12;
    x ^= x << 25;
    x ^= x >> 27;
    *state = x;
    return x * 0x2545F4914F6CDD1DULL;
}

extern "C" {

FFI_EXPORT void native_encrypt_data(uint8_t* data, int32_t length, uint8_t* key, int32_t keyLength) {
    if (!data || !key || length <= 0 || keyLength <= 0) return;
    uint64_t state = 14695981039346656037ULL;
    for (int i = 0; i < keyLength; i++) {
        state ^= key[i];
        state *= 1099511628211ULL;
    }
    for (int32_t i = 0; i < length; i++) {
        uint64_t ks = _xorshift64star(&state);
        uint8_t stream = (uint8_t)(ks ^ (ks >> 8) ^ (ks >> 16) ^ (ks >> 24));
        data[i] ^= stream ^ key[i % keyLength];
    }
}

FFI_EXPORT void secure_chat_encrypt(uint8_t* data, int32_t length, uint32_t sessionKey) {
    // Simple placeholder for ChaCha20 logic
    for (int32_t i = 0; i < length; i++) {
        data[i] ^= (uint8_t)(sessionKey >> (i % 4 * 8));
    }
}

FFI_EXPORT uint64_t generate_message_hash(const char* message, uint64_t timestamp) {
    if (!message) return timestamp;
    uint64_t hash = 14695981039346656037ULL;
    while (*message) {
        hash ^= (uint64_t)(*message++);
        hash *= 1099511628211ULL;
    }
    hash ^= timestamp;
    return hash;
}

FFI_EXPORT uint32_t crc32_checksum(const uint8_t* data, int32_t length) {
    if (!data || length <= 0) return 0;
    uint32_t crc = 0xFFFFFFFF;
    for (int32_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
        }
    }
    return ~crc;
}

}
