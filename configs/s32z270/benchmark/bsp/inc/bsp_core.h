/*==================================================================================================
*   Project              : RTD AUTOSAR 4.7
*   Platform             : CORTEXM
*   Peripheral           :
*   Dependencies         : none
*
*   Autosar Version      : 4.7.0
*   Autosar Revision     : ASR_REL_4_7_REV_0000
*   Autosar Conf.Variant :
*   SW Version           : 2.0.1
*   Build Version        : S32ZE_RTD_2_0_1_D2505_ASR_REL_4_7_REV_0000_20250508
*
*   Copyright 2021-2025 NXP
*
*   NXP Confidential and Proprietary. This software is owned or controlled by NXP and may only be
*   used strictly in accordance with the applicable license terms.  By expressly
*   accepting such terms or by downloading, installing, activating and/or otherwise
*   using the software, you are agreeing that you have read, and that you agree to
*   comply with and are bound by, such license terms.  If you do not agree to be
*   bound by the applicable license terms, then you may not retain, install,
*   activate or otherwise use the software.
==================================================================================================*/

#ifndef CORE_H
#define CORE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "Std_Types.h"

/*
 * @brief Core-specific Interrupt Controller initialization function
 * @param: None
 *
 * @return: None
 */
void Core_IC_Init(void);

/*
 * @brief Core-specific FPU initialization function
 * @param: None
 *
 * @return: None
 */
void Core_FPU_Init(void);

/*
 * @brief Core-specific MPU initialization function
 * @param: None
 *
 * @return: None
 */
void Core_MPU_Init(void);

/*
 * @brief Core-specific Cache initialization function
 * @param: None
 *
 * @return: None
 */
void Core_Cache_Init(void);

#ifdef MCAL_ENABLE_USER_MODE_SUPPORT
#if (MCAL_PLATFORM_ARM == MCAL_ARM_AARCH32) || (MCAL_PLATFORM_ARM == MCAL_ARM_RARCH)
inline static __attribute__((always_inline)) uint32 Core_GoToSupervisor(void)
{
    uint32 retval = 0;
    volatile uint32_t cpsr_val = 0;
    ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val)); /* get current cpsr */
    if (((cpsr_val & 0x1F) != 0x13) && ((cpsr_val & 0x1F) != 0x1F)) {
        ASM_KEYWORD(" mov r12,#0x1"); /*move to value to scratch register indicate that request to
                                         priviledge mode is accepted from trusted sw*/
        ASM_KEYWORD(" svc 0x0");
        retval = 1;
    }
    return retval;
}

inline static __attribute__((always_inline)) uint32
Core_GoToUser_Return(uint32 u32SwitchToSupervisor, uint32 u32returnValue)
{
    volatile uint32_t cpsr_val = 0;
    volatile uint32_t accepted_signal = 0;
    ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val));       /* get current cpsr */
    ASMV_KEYWORD("mov %0, r12\n" : "=r"(accepted_signal)); /* get current r12 values */
    if (((cpsr_val & 0x1F) != 0x10) && (accepted_signal == 0x1U)) {
        ASM_KEYWORD(" svc 0x1");
    }
    ASM_KEYWORD(" mov r12,#0x0");
    (void)u32SwitchToSupervisor;
    return u32returnValue;
}

inline static __attribute__((always_inline)) void Core_GoToUser(void)
{
    volatile uint32_t cpsr_val = 0;
    volatile uint32_t accepted_signal = 0;
    ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val));       /* get current cpsr */
    ASMV_KEYWORD("mov %0, r12\n" : "=r"(accepted_signal)); /* get current r12 values */
    if (((cpsr_val & 0x1F) != 0x10) && (accepted_signal == 0x1U)) {
        ASM_KEYWORD(" svc 0x1");
    }
    ASM_KEYWORD(" mov r12,#0x0");
}
void Core_SuspendInterrupts(void);
void Core_ResumeInterrupts(void);
#else
void Core_SuspendInterrupts(void);
void Core_ResumeInterrupts(void);
uint32 Core_GoToSupervisor(void);
uint32 Core_GoToUser_Return(uint32 u32SwitchToSupervisor, uint32 u32returnValue);
void Core_GoToUser(void);

#endif
#endif
#if (MCAL_PLATFORM_ARM == MCAL_ARM_AARCH32) || (MCAL_PLATFORM_ARM == MCAL_ARM_RARCH)
void Core_EL1SuspendInterrupts(void);
void Core_EL1ResumeInterrupts(void);
#endif
/*
 * @brief Core_disableIsrSource
 * @details function used to disable the interrupt number id
 *
 */
void Core_disableIsrSource(uint16 id);

/*
 * @brief Core_enableIsrSource
 * @details function used to enable the interrupt number id and set up the priority
 *
 */
void Core_enableIsrSource(uint16 id, uint8 prio);

/*
 * @brief Core_registerIsrHandler
 * @details function used to register the interrupt handler in the interrupt vector
 *
 */
void Core_registerIsrHandler(uint16 irq_id, void (*isr_handler)(void));

#ifdef __cplusplus
}
#endif

#endif /* CORE_H */
