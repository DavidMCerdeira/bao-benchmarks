/**
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (c) Bao Project and Contributors. All rights reserved.
 */


#include <config.h>

/**
 * The configuration itself is a struct config that MUST be named config.
 */
struct config config = {
    .shmemlist_size = 1,
    .shmemlist = (struct shmem[]) {
        [0] = {
            .base = 0x32400000,
            .size = 0x100,
        }
    },
    /**
     * This configuration has 2 VM.
     */
    .vmlist_size = 2,
    .vmlist = (struct vm_config[]){
        {
            .image = VM_IMAGE_LOADED(0x32200000, 0x32200000, 0x14000),   // CRAM1 (1MiB)
            .entry = 0x32200000,
            .cpu_affinity = 0x1,
            .platform = {
                .cpu_num = 1,
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        /* CRAM1 (1MiB)*/
                        .base = 0x32200000,
                        .size = 0x100000
                    }
                },
                .ipc_num = 1,
                .ipcs = (struct ipc[]) {
                    {
                        .base = 0x32400000,
                        .size = 0x100,
                        .shmem_id = 0,
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {52}
                    }
                },
                .dev_num = 4,
                .devs =  (struct vm_dev_region[]) {
                    {
                        /* LINFlexD 0 */
                        .pa = 0x40170000,
                        .va = 0x40170000,
                        .size = 0x10000,
                    },
                    {
                        /* SIUL2_0 */
                        .pa = 0x40520000,
                        .va = 0x40520000,
                        .size = 0x1800
                    },
                    {
                        /* MC_CGM_0 - Uart clock */
                        .pa = 0x40030000,
                        .va = 0x40030000,
                        .size = 0x500
                    },
                    {
                        /* System Timer */
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {27}
                    },
                },
                .arch = {
                    .gic = {
                        .gicc_addr = 0x2C000000,
                        .gicd_addr = 0x47800000,
                        .gicr_addr = 0x47900000
                    }
                }
            },
        },
        {
            .image = VM_IMAGE_LOADED(0x32300000, 0x32300000, 0x14000),
            .entry = 0x32300000,
            .cpu_affinity = 0x1,
            .platform = {
                .cpu_num = 1,
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        /* CRAM0 (1MiB)*/
                        .base = 0x32300000,
                        .size = 0x100000
                    },
                },
                .ipc_num = 1,
                .ipcs = (struct ipc[]) {
                    {
                        .base = 0x32400000,
                        .size = 0x100,
                        .shmem_id = 0,
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {52}
                    }
                },
                .dev_num = 3,
                .devs =  (struct vm_dev_region[]) {
                    {
                        /* LINFlexD 0 */
                        .pa = 0x40170000,
                        .va = 0x40170000,
                        .size = 0x10000,
                    },
                    {
                        /* SIUL2_0 */
                        .pa = 0x40520000,
                        .va = 0x40520000,
                        .size = 0x1800
                    },
                    {
                        /* MC_CGM_0 - Uart clock */
                        .pa = 0x40030000,
                        .va = 0x40030000,
                        .size = 0x500
                    },
                },
                .arch = {
                    .gic = {
                        .gicc_addr = 0x2C000000,
                        .gicd_addr = 0x47800000,
                        .gicr_addr = 0x47900000
                    }
                }
            },
        },
    },
};
