/** 
 * Bao, a Lightweight Static Partitioning Hypervisor 
 *
 * Copyright (c) Bao Project (www.bao-project.org), 2019-
 *
 * Authors:
 *      Jose Martins <jose.martins@bao-project.org>
 *      Sandro Pinto <sandro.pinto@bao-project.org>
 *
 * Bao is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License version 2 as published by the Free
 * Software Foundation, with a special exception exempting guest code from such
 * license. See the COPYING file in the top-level directory for details. 
 *
 */

#include <core.h>
#include <stdlib.h>
#include <stdio.h>
#include <cpu.h>
#include <wfi.h>
#include <spinlock.h>
#include <plat.h>
#include <irq.h>
#include <uart.h>
#include <timer.h>
#include <bao.h>
#include <cycle_counter.h>

volatile struct {
    uint32_t context_switch_end_cnt;
} *shared_mem = (void*)SHMEM_BASE;

#define N_TOTAL   1000u
#define N_WARMUP  5u
#define N_MEASURE (N_TOTAL - N_WARMUP)

unsigned long cycles_to_ns(unsigned long cycles, unsigned long freq)
{
    return (unsigned long)(cycles * (float)(1000 * 1000 * 1000 / ((float)freq)));
}

void main(void)
{
    printf("\nBao bare-metal ctx switch 1\n");

    /* set up second guest */
    bao_hypercall(BAO_YIELD_HYPCALL_ID);

    unsigned long min = ~0UL;
    unsigned long max = 0;
    unsigned long avg = 0;

    unsigned long before, after, elapsed;
    unsigned long elapsed_last = 0;

    unsigned k = 0; // measurement sample count (excludes warm-up)

    for (unsigned i = 0; i < N_TOTAL; i++) {
        cycle_counter_prepare();
        before = cycle_counter_get();

        bao_hypercall(BAO_YIELD_HYPCALL_ID);

        after = shared_mem->context_switch_end_cnt;
        elapsed = after - before;

        if (i < N_WARMUP) {
            // warm-up: ignore stats
            continue;
        }

        // update stats on measured samples only
        if (elapsed < min) min = elapsed;
        if (elapsed > max) max = elapsed;

        k++; // 1..N_MEASURE
        long delta = (long)elapsed - (long)avg;
        avg += (unsigned long)(delta / (long)k);
    }

    printf("Ctx switch (measured=%u warmup=%u total=%u):\n",
           k, (unsigned)N_WARMUP, (unsigned)N_TOTAL);

    printf("\tavg: %lu clk cycles %lu ns\n", avg, cycles_to_ns(avg, PLAT_CLK_CPU));
    printf("\tmin: %lu clk cycles %lu ns\n", min, cycles_to_ns(min, PLAT_CLK_CPU));
    printf("\tmax: %lu clk cycles %lu ns\n", max, cycles_to_ns(max, PLAT_CLK_CPU));

    printf("finished\n");
    while (1) wfi();
}

