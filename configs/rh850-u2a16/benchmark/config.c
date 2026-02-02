/**
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (c) Bao Project and Contributors. All rights reserved.
 */

/* THIS CONFIG IS DEFINED FOR TESTING PURPOSES ONLY */

#include <config.h>

struct config config = {

    .shmemlist_size = 1,
    .shmemlist = (struct shmem[]) {
        [0] = { 
            .base = 0xFE170000,
            .size = 0x100, 
        }
    },

    .vmlist_size = 2,

    .vmlist = (struct vm_config[]){
        {
            .entry = 0x10000,
            .image = VM_IMAGE_LOADED(0x010000,0x010000,0x6000),
            .cpu_affinity = 1,

            .platform = {
                .cpu_num = 1,
                .region_num = 2,
                .regions =  (struct vm_mem_region[]) {
                    // Code Flash (Bank A) -> Guest code
                    {
                        .base = 0x10000,
                        .size = 0x6000
                    },
                    // Cluster0 RAM -> Guest Data
                    {
                        .base = 0xfe100000,
                        .size = 0x00008000
                    }
                },

                .ipc_num = 1,
                .ipcs = (struct ipc[]) {
                    {
                        .base = 0xFE170000,
                        .size = 0x100,
                        .shmem_id = 0,
                    }
                },

                .dev_num = 5,
                .devs =  (struct vm_dev_region[]) {
                    // Standby Controller
                    {
                        // 0xFF981000 -> 0xFF982000
                        .pa = 0xFF981000,
                        .va = 0xFF981000,
                        .size = 0x1000,
                        .interrupt_num = 0,
                        .interrupts = NULL,
                    },
                    // RLIN35
                    {
                        // 0xFFC7C100 -> 0xFFC7C140
                        .pa = 0xFFC7C100,
                        .va = 0xFFC7C100,
                        .size = 0x40,
                    },
                    // OSTM0
                    {
                        // 0xFFC7C100 -> 0xFFC7C140
                        .pa = 0xFFBF0000,
                        .va = 0xFFBF0000,
                        .size = 0x100,
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {199}
                    },
                    // INTIF
                    {
                        // 0xFF090000 -> 0xFF090220
                        .pa = 0xFF090000,
                        .va = 0xFF090000,
                        .size = 0x220,
                        .interrupt_num = 0,
                        .interrupts = NULL
                    },
                    // INTC1 (self)
                    {
                        // 0xFFFC0000 -> 0xFFFC4000
                        .pa = 0xFFFC0000,
                        .va = 0xFFFC0000,
                        .size = 0x4000,
                        .interrupt_num = 0,
                        .interrupts = NULL
                    }
                }
            }
        },
        {
            .entry = 0x20000,
            .image = VM_IMAGE_LOADED(0x20000,0x20000,0x6000),
            .cpu_affinity = 1,

            .platform = {
                .cpu_num = 1,
                .region_num = 2,
                .regions =  (struct vm_mem_region[]) {
                    // Code Flash (Bank A) -> Guest code
                    {
                        .base = 0x20000,
                        .size = 0x6000
                    },
                    // Cluster0 RAM -> Guest Data
                    {
                        .base = 0xfe108000,
                        .size = 0x00008000
                    }
                },

                .ipc_num = 1,
                .ipcs = (struct ipc[]) {
                    {
                        .base = 0xFE170000,
                        .size = 0x100,
                        .shmem_id = 0,
                    }
                },

                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    // Standby Controller
                    {
                        // 0xFF981000 -> 0xFF982000
                        .pa = 0xFF981000,
                        .va = 0xFF981000,
                        .size = 0x1000,
                        .interrupt_num = 0,
                        .interrupts = NULL
                    },
                    // RLIN35
                    {
                        // 0xFFC7C100 -> 0xFFC7C140
                        .pa = 0xFFC7C100,
                        .va = 0xFFC7C100,
                        .size = 0x40,
                    },
                }
            }
        },
    }
};


