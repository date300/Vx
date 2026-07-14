#include "vx_filters.h"
#include <algorithm>

extern "C" {

void apply_native_filter(uint8_t* buffer, int32_t width, int32_t height, int32_t filterId) {
    if (!buffer || width <= 0 || height <= 0 || filterId == 0) return;

    int32_t totalPixels = width * height;

    for (int32_t i = 0; i < totalPixels; ++i) {
        int32_t idx = i * 4;
        uint8_t r = buffer[idx];
        uint8_t g = buffer[idx + 1];
        uint8_t b = buffer[idx + 2];
        // uint8_t a = buffer[idx + 3];

        switch (filterId) {
            case 1: { // Grayscale (Luminance method)
                uint8_t gray = (uint8_t)(0.299 * r + 0.587 * g + 0.114 * b);
                buffer[idx] = buffer[idx + 1] = buffer[idx + 2] = gray;
                break;
            }
            case 2: { // Sepia
                int32_t tr = (int32_t)(0.393 * r + 0.769 * g + 0.189 * b);
                int32_t tg = (int32_t)(0.349 * r + 0.686 * g + 0.168 * b);
                int32_t tb = (int32_t)(0.272 * r + 0.534 * g + 0.131 * b);
                buffer[idx]     = (uint8_t)std::min(255, tr);
                buffer[idx + 1] = (uint8_t)std::min(255, tg);
                buffer[idx + 2] = (uint8_t)std::min(255, tb);
                break;
            }
            case 3: { // Invert
                buffer[idx]     = 255 - r;
                buffer[idx + 1] = 255 - g;
                buffer[idx + 2] = 255 - b;
                break;
            }
            case 4: { // Brightness Boost
                buffer[idx]     = (uint8_t)std::min(255, r + 30);
                buffer[idx + 1] = (uint8_t)std::min(255, g + 30);
                buffer[idx + 2] = (uint8_t)std::min(255, b + 30);
                break;
            }
            case 5: { // Cinematic Cold (Cool highlights, slightly desaturated)
                buffer[idx]     = (uint8_t)(r * 0.9); // Reduce Red
                buffer[idx + 1] = (uint8_t)(g * 0.95); // Slightly reduce Green
                buffer[idx + 2] = (uint8_t)std::min(255, (int)(b * 1.1 + 10)); // Boost Blue
                break;
            }
            case 6: { // Teal & Orange (Blockbuster Look)
                buffer[idx]     = (uint8_t)std::min(255, (int)(r * 1.2)); // Orange Highlights
                buffer[idx + 1] = (uint8_t)(g * 1.0);
                buffer[idx + 2] = (uint8_t)std::min(255, (int)(b * 1.1 + 20)); // Teal Shadows
                break;
            }
            case 7: { // Retro (Yellowish / Vintage)
                buffer[idx]     = (uint8_t)std::min(255, (int)(r * 1.1 + 10));
                buffer[idx + 1] = (uint8_t)std::min(255, (int)(g * 1.05 + 5));
                buffer[idx + 2] = (uint8_t)(b * 0.85); // Reduce Blue
                break;
            }
            case 8: { // B&W Noir (High Contrast)
                uint8_t gray = (uint8_t)(0.299 * r + 0.587 * g + 0.114 * b);
                int32_t noir = (gray - 128) * 1.5 + 128; // High contrast
                uint8_t val = (uint8_t)std::max(0, std::min(255, noir));
                buffer[idx] = buffer[idx + 1] = buffer[idx + 2] = val;
                break;
            }
            case 9: { // Warm Sunset
                buffer[idx]     = (uint8_t)std::min(255, (int)(r * 1.3 + 15));
                buffer[idx + 1] = (uint8_t)std::min(255, (int)(g * 1.1));
                buffer[idx + 2] = (uint8_t)(b * 0.9);
                break;
            }
            case 10: { // Cool Night
                buffer[idx]     = (uint8_t)(r * 0.7);
                buffer[idx + 1] = (uint8_t)(g * 0.85);
                buffer[idx + 2] = (uint8_t)std::min(255, (int)(b * 1.4 + 20));
                break;
            }
        }
    }
}

}
