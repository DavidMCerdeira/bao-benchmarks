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

#include <stdio.h>
#include <bao.h>
#include <cycle_counter.h>

volatile struct {
    unsigned long context_switch_end_cnt;
} *shared_mem = (void*)SHMEM_BASE;

void main(void){

    printf("Bao bare-metal ctx switch 2\n");

    while(1) {
        bao_hypercall(BAO_YIELD_HYPCALL_ID);
        shared_mem->context_switch_end_cnt = cycle_counter_get();
    }
}
