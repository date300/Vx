#ifndef VX_PHYSICS_H
#define VX_PHYSICS_H

#include "../../core/vx_common.h"

extern "C" {
FFI_EXPORT double calculate_spring_force(double distance, double velocity, double stiffness, double damping);
FFI_EXPORT double calculate_jiggle_physics(double time, double frequency, double amplitude, double decay);
FFI_EXPORT double fast_lerp(double a, double b, double t);
FFI_EXPORT double calculate_bounce_ease_out(double time, double duration);
FFI_EXPORT double calculate_elastic_collision(double v1, double m1, double v2, double m2, double restitution);
}

#endif // VX_PHYSICS_H
