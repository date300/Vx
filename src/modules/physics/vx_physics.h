#ifndef VX_PHYSICS_H
#define VX_PHYSICS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default")))
#endif

/* ── Scalar (original signature, backward compatible) ── */
FFI_EXPORT double calculate_spring_force(double distance, double velocity, double stiffness, double damping);
FFI_EXPORT double calculate_jiggle_physics(double time, double frequency, double amplitude, double decay);
FFI_EXPORT double fast_lerp(double a, double b, double t);
FFI_EXPORT double calculate_bounce_ease_out(double time, double duration);
FFI_EXPORT double calculate_elastic_collision(double v1, double m1, double v2, double m2, double restitution);
FFI_EXPORT double calculate_liquid_stretch(double pullDistance, double threshold);

/* ── Batch (amortize FFI overhead, 5-20x throughput) ── */
FFI_EXPORT void batch_spring_force(const double* __restrict distance,
                                   const double* __restrict velocity,
                                   const double* __restrict stiffness,
                                   const double* __restrict damping,
                                   double* __restrict out_force,
                                   int64_t count);

FFI_EXPORT void batch_jiggle_physics(const double* __restrict time,
                                     const double* __restrict frequency,
                                     const double* __restrict amplitude,
                                     const double* __restrict decay,
                                     double* __restrict out,
                                     int64_t count);

FFI_EXPORT void batch_lerp(const double* __restrict a,
                           const double* __restrict b,
                           const double* __restrict t,
                           double* __restrict out,
                           int64_t count);

FFI_EXPORT void batch_bounce_ease_out(const double* __restrict time,
                                      const double* __restrict duration,
                                      double* __restrict out,
                                      int64_t count);

FFI_EXPORT void batch_elastic_collision(const double* __restrict v1,
                                        const double* __restrict m1,
                                        const double* __restrict v2,
                                        const double* __restrict m2,
                                        const double* __restrict restitution,
                                        double* __restrict out,
                                        int64_t count);

#ifdef __cplusplus
}
#endif

#endif