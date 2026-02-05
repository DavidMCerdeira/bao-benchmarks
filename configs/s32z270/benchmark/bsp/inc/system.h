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
 *
 *   NXP Confidential and Proprietary. This software is owned or controlled by NXP and may only be
 *   used strictly in accordance with the applicable license terms.  By expressly
 *   accepting such terms or by downloading, installing, activating and/or otherwise
 *   using the software, you are agreeing that you have read, and that you agree to
 *   comply with and are bound by, such license terms.  If you do not agree to be
 *   bound by the applicable license terms, then you may not retain, install,
 *   activate or otherwise use the software.
 */
/*================================================================================================
*   @file    system.h
*   @version 2.0.1
*
*   @brief   AUTOSAR Platform - SYSTEM
*   @details SYSTEM
*            This file contains sample code only. It is not part of the production code
deliverables.
==================================================================================================*/

#ifndef SYSTEM_H
#define SYSTEM_H

#ifdef __cplusplus
extern "C" {
#endif

#include "Std_Types.h"

#define Mode_USR              0x10U
#define Mode_FIQ              0x11U
#define Mode_IRQ              0x12U
#define Mode_SVC              0x13U
#define Mode_MNT              0x16U
#define Mode_ABT              0x17U
#define Mode_HYP              0x1AU
#define Mode_UND              0x1BU
#define Mode_SYS              0x1FU
#define Mode_THUMB            0x20U

#define PHY_CORE_ID_0         (0x0)
#define PHY_CORE_ID_1         (0x1)
#define PHY_CORE_ID_2         (0x2)
#define PHY_CORE_ID_3         (0x3)
#define PHY_CORE_ID_4         (0x4)
#define PHY_CORE_ID_5         (0x5)
#define PHY_CORE_ID_6         (0x6)
#define PHY_CORE_ID_7         (0x7)
#define PHY_CORE_ID_8         (0x8)
#define PHY_CORE_ID_12        (0xC)
#define PHY_CORE_ID_13        (0xD)

#define LOGI_CORE_ID_0        (0x0)
#define LOGI_CORE_ID_1        (0x1)
#define LOGI_CORE_ID_2        (0x2)
#define LOGI_CORE_ID_3        (0x3)

/**
 * @brief Total number of cores that are used in the core id mapping table
 */
#define MAX_ELEMENT_MAP_TABLE (14U)

#ifdef _LINARO_C_S32ZE_
/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASM_KEYWORD  __asm__
/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASMV_KEYWORD __asm__ volatile
#endif

#ifdef _GREENHILLS_C_S32ZE_
/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASM_KEYWORD  __asm

/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASMV_KEYWORD __asm volatile
#endif

#ifdef _DIABDATA_C_S32ZE_
/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASM_KEYWORD  __asm

/**
 * @brief Compiler abstraction for the asm keyword.
 */
#define ASMV_KEYWORD __asm volatile
#endif

/**
 * @brief The data structure is used to map physical core IDsto logical core IDs
 */
typedef struct {
    uint8 u8physicalCoreIdMapping;
    uint8 u8logicalCoreIdMapping;
} CoreMapping_Type;

#if (defined(S32S2XX) || defined(S32E2XX))
/*-----------------------------------------------------------------------*/
/* Enabling the DiPort signals for interrupts etc.*/
/*-----------------------------------------------------------------------*/
void DiPortSignalEnable(void);
#endif
/*
 * @brief Early platform initialization for interrupts, cache and core MPU
 * @param: None
 *
 * @return: None
 */
void SystemInit(void);

/*
 * @brief Default IRQ handler
 * @param: None
 *
 * @return: None
 */
void default_interrupt_routine(void);

#ifdef MCAL_ENABLE_USER_MODE_SUPPORT
#if (MCAL_PLATFORM_ARM == MCAL_ARM_RARCH)
/*
 * @brief Switch to user mode and return the value passed by u32returnValue
 * @param: [in] u8SwitchToSupervisor - if 0, the function will return the value without switching to
 * user mode, if 1, the function will go to user mode before returning the value
 * @param: [in] u32returnValue       - value to be returned
 *
 * @return: u32returnValue
 */
inline static __attribute__((always_inline)) uint32 Sys_GoToUser_Return(uint32 u32SwitchToSupervisor,
    uint32 u32returnValue)
{
    if (u32SwitchToSupervisor == 1) {
        volatile uint32_t cpsr_val = 0;
        /*LDRA_NOANALYSIS*/
        ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val)); /* get current cpsr */
        /*LDRA_ANALYSIS*/
        if ((cpsr_val & 0x1F) != Mode_USR) {
            ASM_KEYWORD(" svc 0x1");
        }
    }

    return u32returnValue;
}
/*
 * @brief Switch to supervisor mode
 * @param: None
 *
 * @return: operation result, 1 if switch was done, 0 if the CPU was already in supervisor mode or
 * in handler mode
 */
inline static __attribute__((always_inline)) uint32 Sys_GoToSupervisor(void)

{
    volatile uint32_t cpsr_val = 0;
    volatile uint32_t accepted_signal = 0;
    /*LDRA_NOANALYSIS*/
    ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val)); /* get current cpsr */
    /*LDRA_ANALYSIS*/
    if (((cpsr_val & 0x1F) != Mode_SVC) && ((cpsr_val & 0x1F) != Mode_SYS) &&
        ((cpsr_val & 0x1F) != Mode_IRQ) && ((cpsr_val & 0x1F) != Mode_FIQ)) {
        /*LDRA_NOANALYSIS*/
        ASMV_KEYWORD(" mov %0,#0x1\n" : "=r"(accepted_signal)); /*move to value to scratch register
                                                                   indicate that request to
                                                                   priviledge mode is accepted from
                                                                   trusted sw*/
        /*LDRA_ANALYSIS*/
        ASM_KEYWORD(" svc 0x0");
    } else {
        /*LDRA_NOANALYSIS*/
        ASMV_KEYWORD(" mov %0,#0x0\n" : "=r"(accepted_signal)); /*move to value to scratch register
                                                                   indicate that request to
                                                                   priviledge mode is not necessary
                                                                 */
        /*LDRA_ANALYSIS*/
    }
    return accepted_signal;
}
/*
 * @brief Switch to user mode
 * @param: None
 *
 * @return: 0
 */
inline static __attribute__((always_inline)) uint32 Sys_GoToUser(void)
{
    volatile uint32_t cpsr_val = 0;
    /*LDRA_NOANALYSIS*/
    ASMV_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val)); /* get current cpsr */
    /*LDRA_ANALYSIS*/
    if ((cpsr_val & 0x1F) != Mode_USR) {
        ASM_KEYWORD(" svc 0x1");
    }

    return 0UL;
}
#endif

/*
 * @brief Sys_SuspendInterrupts
 * @param: None
 *
 * @return: none
 */
void Sys_SuspendInterrupts(void);
void Sys_ResumeInterrupts(void);
#endif

/*
 * @brief Sys_EL1SuspendInterrupts
 * @param: None
 *
 * @return: none
 */
void Sys_EL1ResumeInterrupts(void);
void Sys_EL1SuspendInterrupts(void);

/*
 * @brief Get the hardware id of the currently executing core
 * @param: None
 *
 * @return: coreId
 */
uint8 Sys_GetCoreID(void);

#ifdef __cplusplus
}
#endif

#endif /* SYSTEM_H */
