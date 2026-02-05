/*
 * Copyright 2023 NXP
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include <clock_control_nxp_s32.h>

Clock_Ip_StatusType nxp_s32_clock_init(void)
{
    Clock_Ip_StatusType status;

    status = Clock_Ip_Init(&Clock_Ip_aClockConfig[0]);

    uint64_t volatile freq0 = Clock_Ip_GetClockFrequency(RTU0_CORE_CLK);
    (void)freq0;

    return status;
}
