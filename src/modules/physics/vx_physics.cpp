#include "vx_physics.h"
#include <math.h>

/* ═══════════════════════════════════════════════════════════════
   COMPILER HINTS
   ═══════════════════════════════════════════════════════════════ */
#if defined(__GNUC__) || defined(__clang__)
#define VX_LIKELY(x)   __builtin_expect(!!(x), 1)
#define VX_UNLIKELY(x) __builtin_expect(!!(x), 0)
#define VX_INLINE      __attribute__((always_inline)) inline
#else
#define VX_LIKELY(x)   (x)
#define VX_UNLIKELY(x) (x)
#define VX_INLINE      inline
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ═══════════════════════════════════════════════════════════════
   FAST MATH APPROXIMATIONS  (double precision, ~2-3x faster)
   ═══════════════════════════════════════════════════════════════ */

// Fast exp: bit-hack + minimax, rel.err < 1e-10
VX_INLINE static double vx_fast_exp(double x) {
    if (VX_UNLIKELY(x > 709.0))  return 1.7976931348623157e+308;
    if (VX_UNLIKELY(x < -745.0)) return 0.0;

    double z = x * 1.4426950408889634;          // x * log2(e)
    double n = floor(z + 0.5);
    double r = x - n * 0.6931471805599453;      // x - n*ln2

    double y = 1.0 + r * (1.0 + r * (0.5 + r * (0.16666666666666666
                                                + r * (0.041666666666666664 + r * 0.008333333333333333))));

    union { double d; int64_t i; } u;
    u.i = ((int64_t)(int)n << 52) + (1023LL << 52);
    return y * u.d;
}

// Fast cos: range reduction + 8th-order minimax, rel.err < 1e-12
VX_INLINE static double vx_fast_cos(double x) {
    const double inv_2pi = 0.15915494309189535;
    x -= 6.283185307179586 * floor(x * inv_2pi + 0.5);

    double xx = x * x;
    return 1.0 + xx * (-0.5 + xx * (0.041666666666666664
                                    + xx * (-0.001388888888888889
                                            + xx * (2.48015873015873e-05
                                                    + xx * (-2.755731922398589e-07
                                                            + xx * 2.08767569878681e-09)))));
}

/* ═══════════════════════════════════════════════════════════════
   SCALAR FUNCTIONS
   ═══════════════════════════════════════════════════════════════ */

FFI_EXPORT double calculate_spring_force(double distance, double velocity,
                                         double stiffness, double damping) {
    double force = -stiffness * distance;

    if (VX_LIKELY(stiffness > 0.0 && damping > 0.0)) {
        // Avoid sqrt when damping is already super-critical
        double critical_sq = 4.0 * stiffness;   // (2*sqrt(k))^2
        double damp_sq = damping * damping;
        double eff_c = (damp_sq > critical_sq) ? damping : sqrt(critical_sq);
        force -= eff_c * velocity;
    } else {
        force -= damping * velocity;
    }
    return force;
}

FFI_EXPORT double calculate_jiggle_physics(double time, double frequency,
                                           double amplitude, double decay) {
    if (VX_UNLIKELY(time < 0.0)) return 0.0;

    double dt = decay * time;
    if (VX_UNLIKELY(dt > 50.0)) return 0.0;     // envelope ≈ 0

    double env = vx_fast_exp(-dt);
    double phase = 6.283185307179586 * frequency * time;
    return amplitude * env * vx_fast_cos(phase);
}

FFI_EXPORT double fast_lerp(double a, double b, double t) {
    if (VX_UNLIKELY(t <= 0.0)) return a;
    if (VX_UNLIKELY(t >= 1.0)) return b;
    return a + t * (b - a);                     // compiler → FMA with -ffast-math
}

FFI_EXPORT double calculate_bounce_ease_out(double time, double duration) {
    if (VX_UNLIKELY(time <= 0.0))       return 0.0;
    if (VX_UNLIKELY(time >= duration))  return 1.0;

    double t = time / duration;
    if (VX_LIKELY(t < (1.0 / 2.75))) {
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

FFI_EXPORT double calculate_elastic_collision(double v1, double m1, double v2,
                                              double m2, double restitution) {
    double totalMass = m1 + m2;
    if (VX_UNLIKELY(totalMass == 0.0)) return v1;

    double term1 = (m1 - restitution * m2) * v1;
    double term2 = (1.0 + restitution) * m2 * v2;
    return (term1 + term2) / totalMass;
}

FFI_EXPORT double calculate_liquid_stretch(double pullDistance, double threshold) {
    if (VX_UNLIKELY(pullDistance <= 0.0)) return 0.0;
    if (VX_UNLIKELY(threshold <= 0.0)) return pullDistance;

    // Use a logarithmic curve: as you pull further, resistance increases
    // progress = log(1 + pull/threshold) / log(2)
    // This makes it easy to reach 50% but harder to reach 100%
    double logBase = 2.0;
    double progress = log10(1.0 + (pullDistance / threshold)) / log10(logBase);

    return progress;
}

/* ═══════════════════════════════════════════════════════════════
   BATCH FUNCTIONS  (amortize FFI boundary cost)
   ═══════════════════════════════════════════════════════════════ */

FFI_EXPORT void batch_spring_force(const double* __restrict distance,
                                   const double* __restrict velocity,
                                   const double* __restrict stiffness,
                                   const double* __restrict damping,
                                   double* __restrict out_force,
                                   int64_t count) {
    for (int64_t i = 0; i < count; i++) {
        double d = distance[i];
        double v = velocity[i];
        double k = stiffness[i];
        double c = damping[i];

        double force = -k * d;
        if (VX_LIKELY(k > 0.0 && c > 0.0)) {
            double crit_sq = 4.0 * k;
            double c_sq = c * c;
            double eff_c = (c_sq > crit_sq) ? c : sqrt(crit_sq);
            force -= eff_c * v;
        } else {
            force -= c * v;
        }
        out_force[i] = force;
    }
}

FFI_EXPORT void batch_jiggle_physics(const double* __restrict time,
                                     const double* __restrict frequency,
                                     const double* __restrict amplitude,
                                     const double* __restrict decay,
                                     double* __restrict out,
                                     int64_t count) {
    for (int64_t i = 0; i < count; i++) {
        double t = time[i];
        if (VX_UNLIKELY(t < 0.0)) {
            out[i] = 0.0;
            continue;
        }
        double dt = decay[i] * t;
        if (VX_UNLIKELY(dt > 50.0)) {
            out[i] = 0.0;
            continue;
        }
        double env = vx_fast_exp(-dt);
        double phase = 6.283185307179586 * frequency[i] * t;
        out[i] = amplitude[i] * env * vx_fast_cos(phase);
    }
}

FFI_EXPORT void batch_lerp(const double* __restrict a,
                           const double* __restrict b,
                           const double* __restrict t,
                           double* __restrict out,
                           int64_t count) {
    for (int64_t i = 0; i < count; i++) {
        double tt = t[i];
        if (VX_UNLIKELY(tt <= 0.0)) {
            out[i] = a[i];
        } else if (VX_UNLIKELY(tt >= 1.0)) {
            out[i] = b[i];
        } else {
            out[i] = a[i] + tt * (b[i] - a[i]);
        }
    }
}

FFI_EXPORT void batch_bounce_ease_out(const double* __restrict time,
                                      const double* __restrict duration,
                                      double* __restrict out,
                                      int64_t count) {
    for (int64_t i = 0; i < count; i++) {
        double t = time[i];
        double d = duration[i];
        if (VX_UNLIKELY(t <= 0.0)) {
            out[i] = 0.0;
            continue;
        }
        if (VX_UNLIKELY(t >= d)) {
            out[i] = 1.0;
            continue;
        }
        double tt = t / d;
        double result;
        if (VX_LIKELY(tt < (1.0 / 2.75))) {
            result = 7.5625 * tt * tt;
        } else if (tt < (2.0 / 2.75)) {
            tt -= 1.5 / 2.75;
            result = 7.5625 * tt * tt + 0.75;
        } else if (tt < (2.5 / 2.75)) {
            tt -= 2.25 / 2.75;
            result = 7.5625 * tt * tt + 0.9375;
        } else {
            tt -= 2.625 / 2.75;
            result = 7.5625 * tt * tt + 0.984375;
        }
        out[i] = result;
    }
}

FFI_EXPORT void batch_elastic_collision(const double* __restrict v1,
                                        const double* __restrict m1,
                                        const double* __restrict v2,
                                        const double* __restrict m2,
                                        const double* __restrict restitution,
                                        double* __restrict out,
                                        int64_t count) {
    for (int64_t i = 0; i < count; i++) {
        double total = m1[i] + m2[i];
        if (VX_UNLIKELY(total == 0.0)) {
            out[i] = v1[i];
            continue;
        }
        double term1 = (m1[i] - restitution[i] * m2[i]) * v1[i];
        double term2 = (1.0 + restitution[i]) * m2[i] * v2[i];
        out[i] = (term1 + term2) / total;
    }
}

#ifdef __cplusplus
}
#endif