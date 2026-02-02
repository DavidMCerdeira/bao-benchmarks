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

#define TIMER_INTERVAL 1

#define N_TOTAL   1000u
#define N_WARMUP  200u
#define N_MEASURE (N_TOTAL - N_WARMUP)

static inline unsigned long cycles_to_ns(unsigned long cycles, unsigned long freq)
{
    return (unsigned long)(cycles * (float)(1000 * 1000 * 1000 / ((float)freq)));
}

/* Updated in ISR, read in main */
static volatile unsigned sample_idx = 0;          // 0..N_TOTAL-1
static volatile unsigned meas_count = 0;          // 0..N_MEASURE
static volatile unsigned long lat_min = ~0UL;
static volatile unsigned long lat_max = 0;
static volatile unsigned long lat_avg = 0;        // running average (cycles)

void timer_handler(unsigned int id)
{
    (void)id;

    unsigned long latency = timer_get() - TIMER_INTERVAL;

    unsigned i = sample_idx;   // capture current index
    sample_idx = i + 1;

    if (i >= N_WARMUP && meas_count < N_MEASURE) {

        if (latency < lat_min) lat_min = latency;
        if (latency > lat_max) lat_max = latency;

        // running average over measured samples only
        unsigned k = meas_count + 1;  // 1..N_MEASURE
        long delta = (long)latency - (long)lat_avg;
        lat_avg += (unsigned long)(delta / (long)k);

        meas_count = k;
    }
}

void main(void)
{
    printf("\nBao bare-metal irq-lat WCE 1\n");

    timer_enable();
    irq_set_handler(TIMER_IRQ_ID, timer_handler);
    irq_enable(TIMER_IRQ_ID);

    // Drive the experiment: program timer, yield, repeat
    for (unsigned i = 0; i < N_TOTAL; i++) {
        timer_set(TIMER_INTERVAL);
        bao_hypercall(BAO_YIELD_HYPCALL_ID);
    }

    // Ensure the last interrupt has fired (otherwise you can miss the final sample)
    while (sample_idx < N_TOTAL) { }

    unsigned long ns_avg = cycles_to_ns((unsigned long)lat_avg, (unsigned long)TIMER_FREQ);
    unsigned long ns_min = cycles_to_ns((unsigned long)lat_min, (unsigned long)TIMER_FREQ);
    unsigned long ns_max = cycles_to_ns((unsigned long)lat_max, (unsigned long)TIMER_FREQ);

    printf("IRQ latency, measured=%u (warmup=%u total=%u)\n",
           (unsigned)meas_count,
           (unsigned)N_WARMUP,
           (unsigned)N_TOTAL);

    printf("\tavg: %lu timer cycles %lu ns\n", (unsigned long)lat_avg, ns_avg);
    printf("\tmin: %lu timer cycles %lu ns\n", (unsigned long)lat_min, ns_min);
    printf("\tmax: %lu timer cycles %lu ns\n", (unsigned long)lat_max, ns_max);

    printf("finished\n");
    while (1) wfi();
}

