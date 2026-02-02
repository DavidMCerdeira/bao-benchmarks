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

#define TIMER_INTERVAL   (TIME_MS(1))

#define N_TOTAL          1000u
#define N_WARMUP         2u
#define N_MEASURE        (N_TOTAL - N_WARMUP)

static inline unsigned long cycles_to_ns(unsigned long cycles, unsigned long freq)
{
    return (unsigned long)(cycles * (float)(1000 * 1000 * 1000 / ((float)freq)));
}

volatile unsigned c = N_TOTAL;

// stats (updated in ISR, printed in main)
volatile unsigned      meas_count = 0;     // 0..N_MEASURE
volatile unsigned long lat_min = ~0UL;
volatile unsigned long lat_max = 0;
volatile unsigned long lat_avg = 0;        // running average in cycles (integer)

void timer_handler(unsigned int id)
{
    (void)id;

    // latency in timer cycles
    unsigned long latency = timer_get() - TIMER_INTERVAL;

    unsigned sample_idx = N_TOTAL - c; // 0..N_TOTAL-1 (assuming c decremented once per IRQ)

    // skip warm-up samples
    if (sample_idx >= N_WARMUP && meas_count < N_MEASURE) {

        if (latency < lat_min) lat_min = latency;
        if (latency > lat_max) lat_max = latency;

        // running average over measurement samples only
        meas_count++;
        long delta = (long)latency - (long)lat_avg;
        lat_avg += (unsigned long)(delta / (long)meas_count);
    }

    if (c > 0) {
        c--;
        timer_set(TIMER_INTERVAL);
    }
}

void platform_custom_init(void);

void main(void)
{
    platform_custom_init();
    uart_init();

    printf("\n\nBao bare-metal native irq-lat\n");

    timer_enable();
    irq_set_handler(TIMER_IRQ_ID, timer_handler);
    irq_enable(TIMER_IRQ_ID);
    timer_set(TIMER_INTERVAL);

    while (c) { }   // wait until all samples collected

    unsigned long ns_avg = cycles_to_ns((unsigned long)lat_avg, (unsigned long)TIMER_FREQ);
    unsigned long ns_min = cycles_to_ns((unsigned long)lat_min, (unsigned long)TIMER_FREQ);
    unsigned long ns_max = cycles_to_ns((unsigned long)lat_max, (unsigned long)TIMER_FREQ);

    printf("IRQ latency, measured=%u (warmup=%u)\n",
           (unsigned)meas_count, (unsigned)N_WARMUP);

    printf("\tavg: %lu timer cycles  %lu ns\n", (unsigned long)lat_avg, ns_avg);
    printf("\tmin: %lu timer cycles  %lu ns\n", (unsigned long)lat_min, ns_min);
    printf("\tmax: %lu timer cycles  %lu ns\n", (unsigned long)lat_max, ns_max);

    printf("finished\n");
    while (1) ;
}

