#include "vx_physics.h"
#include <math.h>

extern "C" {

FFI_EXPORT double calculate_spring_force(double distance, double velocity, double stiffness, double damping) {
    double critical = 2.0 * sqrt(stiffness);
    double effective_damping = (damping > critical) ? damping : critical;
    return -stiffness * distance - effective_damping * velocity;
}

FFI_EXPORT double calculate_jiggle_physics(double time, double frequency, double amplitude, double decay) {
    if (time < 0.0) return 0.0;
    return amplitude * exp(-decay * time) * cos(6.283185307179586 * frequency * time);
}

FFI_EXPORT double fast_lerp(double a, double b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a + t * (b - a);
}

FFI_EXPORT double calculate_bounce_ease_out(double time, double duration) {
    if (time <= 0.0) return 0.0;
    if (time >= duration) return 1.0;
    double t = time / duration;
    if (t < (1.0 / 2.75)) {
        return 7.5625 * t * t;
    } else if (t < (2.0 / 2.75)) {
        t -= 1.5 / 2.75;
        return 7.5625 * t * t + 0.75;
    } else if (t < (2.5 / 2.75)) {
        t -= 2.25 / 2.75;
        return 7.5625 * t * t + 0.9375;
    } else {
        t -= 2.625 / 2.75;
        return 7.5625 * t * t + 0.984375;
    }
}

FFI_EXPORT double calculate_elastic_collision(double v1, double m1, double v2, double m2, double restitution) {
    double totalMass = m1 + m2;
    if (totalMass == 0.0) return v1;
    return ((m1 - restitution * m2) * v1 + (1.0 + restitution) * m2 * v2) / totalMass;
}

}
