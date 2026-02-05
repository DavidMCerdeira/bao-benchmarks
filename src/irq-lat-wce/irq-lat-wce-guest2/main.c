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

#define SMCC64_BIT              (0x40000000)
#define SMCC32_FID_VND_HYP_SRVC (0x86000000)
#define SMCC64_FID_VND_HYP_SRVC (SMCC32_FID_VND_HYP_SRVC | SMCC64_BIT)

void main(void){

    printf("Bao bare-metal irq-lat WCE 2\n");

    while(1) {
        bao_hypercall(BAO_YIELD_HYPCALL_ID | SMCC64_FID_VND_HYP_SRVC);
    }
}
