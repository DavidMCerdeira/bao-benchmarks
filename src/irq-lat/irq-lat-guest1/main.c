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

#define TIMER_INTERVAL (TIME_MS(1))

volatile unsigned c = 1000;
volatile unsigned long irq_lat = 0;
void timer_handler(unsigned int id){
    char str[50];
    unsigned long latency = timer_get() - TIMER_INTERVAL;
    if(c < 800){
        if(latency > irq_lat) {
            irq_lat = latency;
        }
    }
    if(c>0){
        c--;
        timer_set(TIMER_INTERVAL);
    }
    else {
        irq_disable(TIMER_IRQ_ID);
    }
}

void test_freq(uint64_t seconds, int it)
{
    //check timer freq is correct. loop for 10 seconds
    for (int i = 0; i < it; i++) {
        uint64_t start = timer_get();
        while((timer_get() - start) < TIME_S(seconds));
        printf("Time stamp %d\n", i+1);
    }
}

void main(void){

    printf("Bao bare-metal irq-lat 1\n");

    //test_freq(10, 3);

    timer_enable();
    irq_set_handler(TIMER_IRQ_ID, timer_handler);
    timer_set(TIMER_INTERVAL);
    irq_enable(TIMER_IRQ_ID);
    irq_set_prio(TIMER_IRQ_ID, IRQ_MAX_PRIO);
    while(c){
        wfi();
    }

    printf("IRQ latency:\t%u\n", (unsigned long)irq_lat);
    printf("finished\n");
    while(1)
        wfi();
}
