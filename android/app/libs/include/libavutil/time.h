#ifndef AVUTIL_TIME_H
#define AVUTIL_TIME_H

#include <stdint.h>

/**
 * Get the current time in microseconds.
 */
int64_t av_gettime(void);

/**
 * Get the current time in microseconds from a monotonic clock.
 */
int64_t av_gettime_relative(void);

/**
 * Sleep for a period of time in microseconds.
 */
int av_usleep(unsigned usec);

#endif /* AVUTIL_TIME_H */
