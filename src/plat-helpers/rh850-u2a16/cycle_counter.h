#ifndef __ARCH_CYCLE_COUNTER
#define __ARCH_CYCLE_COUNTER

#include <stdint.h>
#include <srs.h>

static inline uint64_t read_tscount64(void)
{
    uint32_t hi1, lo, hi2;

    do {
        hi1 = get_tscounth();
        lo  = get_tscountl();
        hi2 = get_tscounth();
    } while (hi1 != hi2);

    return ((uint64_t)hi2 << 32) | lo;
}

static inline unsigned long cycle_counter_get()
{
    return (unsigned long)read_tscount64();
}

static inline void cycle_counter_prepare()
{
    /* counter must be enabled by the hyp when running in VM mode */
}

#endif /* __ARCH_CYCLE_COUNTER */
