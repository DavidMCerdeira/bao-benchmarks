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
*   @file    system.c
*   @version 2.0.1
*
*   @brief   Platform - SYSTEM
*   @details SYSTEM
*            This file contains sample code only. It is not part of the production code
deliverables.
==================================================================================================*/

#ifdef __cplusplus
extern "C" {
#endif

/*==================================================================================================
*                                         INCLUDE FILES
* 1) system and project includes
* 2) needed interfaces from external units
* 3) internal and external interfaces from this unit
==================================================================================================*/
#include "Mcal.h"
#include "system.h"
#include "bsp_core.h"

#if (defined(S32E2XX) || defined(S32S2XX))
#include "S32E2_MSCM.h"
#include "S32E2_MC_ME.h"
#include "S32E2_MC_RGM.h"
#include "S32E2_GPR3.h"
#include "S32E2_RDC.h"
#include "S32E2_RTUP_NIC_B.h"
#include "S32E2_RTUM_NIC_D.h"
#include "S32E2_RTUF_NIC_D.h"
#include "S32E2_RTUE_NIC_D.h"
#include "S32E2_RTU_GPR.h"
#include "S32E2_DIPORTSD.h"
#include "S32E2_DIPORTSD_AE.h"
#include "S32E2_AIPS_LITE.h"
#elif defined(S32Z2XX)
#include "S32Z2_MSCM.h"
#include "S32Z2_MC_ME.h"
#include "S32Z2_MC_RGM.h"
#include "S32Z2_GPR3.h"
#include "S32Z2_RDC.h"
#include "S32Z2_RTUP_NIC_B.h"
#include "S32Z2_RTUM_NIC_D.h"
#include "S32Z2_RTUF_NIC_D.h"
#include "S32Z2_RTUE_NIC_D.h"
#include "S32Z2_RTU_GPR.h"
#endif

/*==================================================================================================
*                                      FILE VERSION CHECKS
==================================================================================================*/

/*==================================================================================================
*                          LOCAL TYPEDEFS (STRUCTURES, UNIONS, ENUMS)
==================================================================================================*/

/*==================================================================================================
*                                       LOCAL CONSTANTS
==================================================================================================*/

/*==================================================================================================
*                                       LOCAL MACROS
==================================================================================================*/

#define RTU_0_R52_0  (0UL)
#define RTU_0_R52_1  (1UL)
#define RTU_0_R52_2  (2UL)
#define RTU_0_R52_3  (3UL)
#define RTU_1_R52_0  (4UL)
#define RTU_1_R52_1  (5UL)
#define RTU_1_R52_2  (6UL)
#define RTU_1_R52_3  (7UL)
#define SMU          (8UL)
#define CE_0         (12UL)
#define CE_1         (13UL)
#define INVALID_CORE (0xFF)
/*==================================================================================================
*                                       LOCAL VARIABLES
==================================================================================================*/

/*==================================================================================================-
*                                       GLOBAL CONSTANTS
==================================================================================================*/

/*==================================================================================================
*                                       GLOBAL VARIABLES
==================================================================================================*/
#define PLATFORM_START_SEC_VAR_CLEARED_32
// #include "Platform_MemMap.h"
/* Allocate a global variable which will be overwritten by the debugger if attached(in CMM), to
 * catch the core after reset. */
uint32 RESET_CATCH_CORE;
#define PLATFORM_STOP_SEC_VAR_CLEARED_32
// #include "Platform_MemMap.h"

#define PLATFORM_START_SEC_CONST_8
// #include "Platform_MemMap.h"
/**
 * @brief The core id mapping table
 *
 * @note  - The table can be defined by user to be compatible with the specific context
 *
 */
#ifndef TOTAL_ELEMENT_MAP_TABLE
/**
 * @brief Total number of elements in the CoreID mapping table
 */
#define TOTAL_ELEMENT_MAP_TABLE (11U)
#endif
__attribute__((weak)) const CoreMapping_Type axCoreMappingTable[TOTAL_ELEMENT_MAP_TABLE] = {
    { PHY_CORE_ID_0, LOGI_CORE_ID_0 }, /* PhysicalID 0  - [Cluster0-Core0-RTU0] is mapped to logical
                                          ID 0 */
    { PHY_CORE_ID_1, LOGI_CORE_ID_1 }, /* PhysicalID 1  - [Cluster0-Core1-RTU0] is mapped to logical
                                          ID 1 */
    { PHY_CORE_ID_2, LOGI_CORE_ID_2 }, /* PhysicalID 2  - [Cluster1-Core0-RTU0] is mapped to logical
                                          ID 2 */
    { PHY_CORE_ID_3, LOGI_CORE_ID_3 }, /* PhysicalID 3  - [Cluster1-Core1-RTU0] is mapped to logical
                                          ID 3 */
    { PHY_CORE_ID_4, LOGI_CORE_ID_0 }, /* PhysicalID 4  - [Cluster0-Core0-RTU1] is mapped to logical
                                          ID 0 */
    { PHY_CORE_ID_5, LOGI_CORE_ID_1 }, /* PhysicalID 5  - [Cluster0-Core0-RTU1] is mapped to logical
                                          ID 1 */
    { PHY_CORE_ID_6, LOGI_CORE_ID_2 }, /* PhysicalID 6  - [Cluster0-Core0-RTU1] is mapped to logical
                                          ID 2 */
    { PHY_CORE_ID_7, LOGI_CORE_ID_3 }, /* PhysicalID 7  - [Cluster0-Core0-RTU1] is mapped to logical
                                          ID 3 */
    { PHY_CORE_ID_8, LOGI_CORE_ID_0 }, /* PhysicalID 8  - [SMU]                 is mapped to logical
                                          ID 0 */
    { PHY_CORE_ID_12, LOGI_CORE_ID_0 }, /* PhysicalID 12 - [Core0-CE]            is mapped to
                                           logical ID 0 */
    { PHY_CORE_ID_13, LOGI_CORE_ID_1 } /* PhysicalID 13 - [Core1-CE]            is mapped to logical
                                          ID 1 */
};
#define PLATFORM_STOP_SEC_CONST_8
// #include "Platform_MemMap.h"
/*==================================================================================================
*                                   LOCAL FUNCTION PROTOTYPES
==================================================================================================*/

/*==================================================================================================
*                                       LOCAL FUNCTIONS
==================================================================================================*/

/*==================================================================================================
*                                       GLOBAL FUNCTIONS
==================================================================================================*/

#if (defined(S32S2XX) || defined(S32E2XX))
/*-----------------------------------------------------------------------*/
/* Enabling the DiPort signals for interrupts etc.*/
/*-----------------------------------------------------------------------*/

void DiPortSignalEnable(void)
{
    IP_DIPORTSD->SIGEN = 0xFF;    /*Enable all signaling via diPort on Master side*/
    IP_DIPORTSD_AE->SIGEN = 0xFF; /*Enable all signaling via diPort on Slave side*/
}

/*-----------------------------------------------------------------------*/
/* Disable supervisor protection of AE peripherals through AIPS_Lite_AE  */
/*-----------------------------------------------------------------------*/
void DisableSvcProtection_AE(void)
{
    IP_AIPS_LITE_AE->PACRA = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRA = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRB = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRC = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRD = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRE = 0x00000000UL;
    IP_AIPS_LITE_AE->OPACRF = 0x00000000UL;
}

/*================================================================================================*/
/**
 * @brief Sys_InitAeSram
 * @details Function used to initialize AE SRAM
 */
/*================================================================================================*/
static void Sys_InitAeSram(void)
{
    extern uint64 __RAM_AE_SHAREABLE_START[];
    extern uint64 __ROM_AE_SHAREABLE_START[];
    extern uint64 __ROM_AE_SHAREABLE_END[];
    extern uint64 __INT_AE_SRAM_START[];
    extern uint64 __INT_AE_SRAM_END[];

    volatile const uint64* rom;
    volatile const uint8* rom8;
    volatile uint64* ram;
    volatile uint8* ram8;
    volatile uint32 size = 0U;
    volatile uint32 i = 0U;
    volatile uint8 dataPad = 0U;

    /* Initialize AE SRAM (included .bss section) */
    ram = (uint64*)__INT_AE_SRAM_START;
    size = (uint32)__INT_AE_SRAM_END - (uint32)ram;
    for (i = 0U; i < (size >> 3U); i++) {
        ram[i] = 0U;
    }
    /* Since the size of the section always aligns with 64bits according to the sample file linker.
        Zeroing the last 8 bytes of the section if the data to be used of program does not align
       with 8.*/
    if ((size & 0x7U) != 0U) {
        ram[i] = 0U;
    }

    /* Copy initialized table */
    rom = (uint64*)__ROM_AE_SHAREABLE_START;
    ram = (uint64*)__RAM_AE_SHAREABLE_START;
    size = (uint32)__ROM_AE_SHAREABLE_END - (uint32)rom;
    dataPad = size & 0x7U;
    for (i = 0U; i < ((size - dataPad) >> 3U); i++) {
        ram[i] = rom[i];
    }
    /* For the rest of data, copy 1 bytes at per one read */
    rom8 = (uint8*)&(rom[i]);
    ram8 = (uint8*)&(ram[i]);
    for (i = 0U; i < dataPad; i++) {
        ram8[i] = rom8[i];
    }
}
#endif /* (defined(S32S2XX) || defined(S32E2XX)) */
/*================================================================================================*/
/**
 * @brief    startup_go_to_user_mode
 * @details  Function called from startup.s to switch to user mode if MCAL_ENABLE_USER_MODE_SUPPORT
 *           is defined
 */
/*================================================================================================*/
void startup_go_to_user_mode(void);
void startup_go_to_user_mode(void)
{
#ifdef MCAL_ENABLE_USER_MODE_SUPPORT
#if (MCAL_PLATFORM_ARM == MCAL_ARM_MARCH)
    Core_GoToUser();
#else
    ASM_KEYWORD(" svc 0x1");
#endif
#endif
}

#ifdef MCAL_ENABLE_USER_MODE_SUPPORT
#if (MCAL_PLATFORM_ARM == MCAL_ARM_MARCH)
uint32 Sys_GoToSupervisor(void)
{
    return Core_GoToSupervisor();
}

uint32 Sys_GoToUser_Return(uint32 u32SwitchToSupervisor, uint32 u32returnValue)
{
    return Core_GoToUser_Return(u32SwitchToSupervisor, u32returnValue);
}

uint32 Sys_GoToUser(void)
{
    Core_GoToUser();
    return 0UL;
}
#endif
void Sys_SuspendInterrupts(void)
{
    Core_SuspendInterrupts();
}

void Sys_ResumeInterrupts(void)
{
    Core_ResumeInterrupts();
}
#endif
#if (MCAL_PLATFORM_ARM == MCAL_ARM_AARCH32) || (MCAL_PLATFORM_ARM == MCAL_ARM_RARCH)
void Sys_EL1SuspendInterrupts(void)
{
    Core_EL1SuspendInterrupts();
}

void Sys_EL1ResumeInterrupts(void)
{
    Core_EL1ResumeInterrupts();
}
#endif
/*================================================================================================*/
/**
 * @brief   Sys_GetCoreID
 * @details Function used to get the ID of the currently executing thread
 */
/*================================================================================================*/
#if !defined(USING_OS_AUTOSAROS)
uint8 Sys_GetCoreID(void)
{
    uint8 u8RunningCoreId = IP_MSCM->CPXNUM & MSCM_CPXNUM_CPN_MASK;
    uint8 u8Count = 0;
    uint8 u8CoreRetVal = INVALID_CORE;

    while (u8Count < TOTAL_ELEMENT_MAP_TABLE) {
        if (u8RunningCoreId == axCoreMappingTable[u8Count].u8physicalCoreIdMapping) {
            u8CoreRetVal = axCoreMappingTable[u8Count].u8logicalCoreIdMapping;
            break;
        }
        u8Count++;
    }

    if (INVALID_CORE == u8CoreRetVal) {
        /* It’s possible for a hardware failure to occur, resulting in an infinite loop */
        while (1)
            ;
    }

    return u8CoreRetVal;
}
#endif
/*================================================================================================*/
/**
 * @brief Sys_PartitionsTurnOn
 * @details Function used to turn on partitions
 */
/*================================================================================================*/
#if (defined(START_CR52_0_0) || defined(START_CR52_0_1) || defined(START_CR52_0_2) || \
    defined(START_CR52_0_3) || defined(START_CR52_1_0) || defined(START_CR52_1_1) ||  \
    defined(START_CR52_1_2) || defined(START_CR52_1_3) || defined(START_CM33_0))
static void Sys_PartitionsTurnOn(void)
{
    /* Turn on RTU0 partition if M33 core is boot core */
#if (defined(CORE_M33_0) &&                                                           \
    (defined(START_CR52_0_0) || defined(START_CR52_0_1) || defined(START_CR52_0_2) || \
        defined(START_CR52_0_3)))
    /* Enable partition clock */
    IP_MC_ME->PRTN1_PCONF |= MC_ME_PRTN1_PCONF_PCE_MASK;
    IP_MC_ME->PRTN1_PUPD |= MC_ME_PRTN1_PUPD_PCUD_MASK;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (!(IP_MC_ME->PRTN1_STAT & MC_ME_PRTN1_STAT_PCS_MASK))
        ;
    /* Release partition to exit reset */
    IP_MC_RGM->PRST_0[1].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_64_RST_MASK;
    /* Disable OSS  */
    IP_MC_ME->PRTN1_PCONF &= ~MC_ME_PRTN1_PCONF_OSSE_MASK;
    IP_MC_ME->PRTN1_PUPD |= MC_ME_PRTN1_PUPD_OSSUD_MASK;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (IP_MC_RGM->PSTAT_0[1].PSTAT_0 & MC_RGM_PRST_0_PERIPH_64_RST_MASK)
        ;
    while (IP_MC_ME->PRTN1_STAT & MC_ME_PRTN1_STAT_OSSS_MASK)
        ;
    /* Deactivate RTU0 fencing logic and enable SRAM interface */
    IP_GPR3->RTU0FDC = 0U;
    IP_RDC_0->RD1_CTRL_REG |= RDC_RD1_CTRL_REG_RD1_CTRL_UNLOCK_MASK;
    IP_RDC_0->RD1_CTRL_REG &= ~RDC_RD1_CTRL_REG_RD1_INTERCONNECT_INTERFACE_DISABLE_MASK;
    while (IP_RDC_0->RD1_STAT_REG & RDC_RD1_STAT_REG_RD1_INTERCONNECT_INTERFACE_DISABLE_STAT_MASK)
        ;
#endif
        /* Turn on RTU1 partition */
#if (defined(START_CR52_1_0) || defined(START_CR52_1_1) || defined(START_CR52_1_2) || \
    defined(START_CR52_1_3))
    /* Enable partition clock */
    IP_MC_ME->PRTN2_PCONF |= MC_ME_PRTN2_PCONF_PCE_MASK;
    IP_MC_ME->PRTN2_PUPD |= MC_ME_PRTN2_PUPD_PCUD_MASK;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (!(IP_MC_ME->PRTN2_STAT & MC_ME_PRTN2_STAT_PCS_MASK))
        ;
    /* Release partition to exit reset */
    IP_MC_RGM->PRST_0[2].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_128_RST_MASK;
    /* Disable OSS  */
    IP_MC_ME->PRTN2_PCONF &= ~MC_ME_PRTN2_PCONF_OSSE_MASK;
    IP_MC_ME->PRTN2_PUPD |= MC_ME_PRTN2_PUPD_OSSUD_MASK;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (IP_MC_RGM->PSTAT_0[2].PSTAT_0 & MC_RGM_PRST_0_PERIPH_128_RST_MASK)
        ;
    while (IP_MC_ME->PRTN2_STAT & MC_ME_PRTN2_STAT_OSSS_MASK)
        ;
    /* Deactivate RTU1 fencing logic and enable SRAM interface */
    IP_GPR3->RTU1FDC = 0U;
    IP_RDC_1->RD1_CTRL_REG |= RDC_RD1_CTRL_REG_RD1_CTRL_UNLOCK_MASK;
    IP_RDC_1->RD1_CTRL_REG &= ~RDC_RD1_CTRL_REG_RD1_INTERCONNECT_INTERFACE_DISABLE_MASK;
    while (IP_RDC_1->RD1_STAT_REG & RDC_RD1_STAT_REG_RD1_INTERCONNECT_INTERFACE_DISABLE_STAT_MASK)
        ;
    /* Configure REMAP for NICs */
    IP_RTU1__RTUM_NIC_D->REMAP = 0x02U;
    IP_RTU1__RTUF_NIC_D->REMAP = 0x02U;
    IP_RTU1__RTUP_NIC_B->REMAP = 0x02U;
    IP_RTU1__RTUE_NIC_D->REMAP = 0x02U;
#endif
}
/*================================================================================================*/
/**
 * @brief Sys_StartSecondaryCores
 * @details Function used to start the secondary cores
 */
/*================================================================================================*/
static void Sys_StartSecondaryCores(void)
{
    /* Turn on partitions */
    Sys_PartitionsTurnOn();
    /* Configure Split-lock RTU0 if M33 core is boot core */
#if (defined(CORE_M33_0) &&                                                           \
    (defined(START_CR52_0_0) || defined(START_CR52_0_1) || defined(START_CR52_0_2) || \
        defined(START_CR52_0_3)))
#ifndef RTU0_R52_LOCKSTEP_MODE
    IP_RTU0__GPR->CFG_CORE |= RTU_GPR_CFG_CORE_SPLT_LCK_MASK;
#endif
#endif
    /* Configure Split-lock RTU1 */
#if (defined(START_CR52_1_0) || defined(START_CR52_1_1) || defined(START_CR52_1_2) || \
    defined(START_CR52_1_3))
#ifndef RTU1_R52_LOCKSTEP_MODE
    IP_RTU1__GPR->CFG_CORE |= RTU_GPR_CFG_CORE_SPLT_LCK_MASK;
#endif
#endif
    /* Release secondary cores to exit reset */
#ifdef START_CR52_0_0
    extern const uint32 __CORE_R52_0_0_START_ADDRESS;

    IP_MC_ME->PRTN1_CORE0_ADDR = (uint32)&__CORE_R52_0_0_START_ADDRESS;
    IP_MC_ME->PRTN1_CORE0_PCONF = 1;
    IP_MC_ME->PRTN1_CORE0_PUPD = 1;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (!(IP_MC_ME->PRTN1_CORE0_STAT & MC_ME_PRTN1_CORE0_STAT_CCS_MASK)) { };
    IP_MC_RGM->PRST_0[1].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_65_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[1].PSTAT_0 & MC_RGM_PRST_0_PERIPH_65_RST_MASK)
        ;
#endif /*START_CR52_0_0*/
#ifdef START_CR52_0_1
    extern const uint32 __CORE_R52_0_1_START_ADDRESS;

    IP_MC_ME->PRTN1_CORE1_ADDR = (uint32)&__CORE_R52_0_1_START_ADDRESS;
#ifndef RTU0_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN1_CORE0_STAT & MC_ME_PRTN1_CORE0_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN1_CORE0_PCONF = 1;
        IP_MC_ME->PRTN1_CORE0_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN1_CORE0_STAT & MC_ME_PRTN1_CORE0_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[1].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_66_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[1].PSTAT_0 & MC_RGM_PRST_0_PERIPH_66_RST_MASK)
        ;
#endif /*START_CR52_0_1*/
#ifdef START_CR52_0_2
    extern const uint32 __CORE_R52_0_2_START_ADDRESS;

    IP_MC_ME->PRTN1_CORE2_ADDR = (uint32)&__CORE_R52_0_2_START_ADDRESS;
#ifndef RTU0_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN1_CORE2_STAT & MC_ME_PRTN1_CORE2_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN1_CORE2_PCONF = 1;
        IP_MC_ME->PRTN1_CORE2_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN1_CORE2_STAT & MC_ME_PRTN1_CORE2_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[1].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_67_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[1].PSTAT_0 & MC_RGM_PRST_0_PERIPH_67_RST_MASK)
        ;
#endif /*START_CR52_0_2*/
#ifdef START_CR52_0_3
    extern const uint32 __CORE_R52_0_3_START_ADDRESS;

    IP_MC_ME->PRTN1_CORE3_ADDR = (uint32)&__CORE_R52_0_3_START_ADDRESS;
#ifndef RTU0_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN1_CORE2_STAT & MC_ME_PRTN1_CORE2_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN1_CORE2_PCONF = 1;
        IP_MC_ME->PRTN1_CORE2_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN1_CORE2_STAT & MC_ME_PRTN1_CORE2_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[1].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_68_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[1].PSTAT_0 & MC_RGM_PRST_0_PERIPH_68_RST_MASK)
        ;
#endif /*START_CR52_0_3*/
#ifdef START_CR52_1_0
    extern const uint32 __CORE_R52_1_0_START_ADDRESS;

    IP_MC_ME->PRTN2_CORE0_ADDR = (uint32)&__CORE_R52_1_0_START_ADDRESS;
    IP_MC_ME->PRTN2_CORE0_PCONF = 1;
    IP_MC_ME->PRTN2_CORE0_PUPD = 1;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (!(IP_MC_ME->PRTN2_CORE0_STAT & MC_ME_PRTN2_CORE0_STAT_CCS_MASK)) { };
    IP_MC_RGM->PRST_0[2].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_129_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[2].PSTAT_0 & MC_RGM_PRST_0_PERIPH_129_RST_MASK)
        ;
#endif /*START_CR52_1_0*/
#ifdef START_CR52_1_1
    extern const uint32 __CORE_R52_1_1_START_ADDRESS;

    IP_MC_ME->PRTN2_CORE1_ADDR = (uint32)&__CORE_R52_1_1_START_ADDRESS;
#ifndef RTU1_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN2_CORE0_STAT & MC_ME_PRTN2_CORE0_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN2_CORE0_PCONF = 1;
        IP_MC_ME->PRTN2_CORE0_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN2_CORE0_STAT & MC_ME_PRTN2_CORE0_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[2].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_130_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[2].PSTAT_0 & MC_RGM_PRST_0_PERIPH_130_RST_MASK)
        ;
#endif /*START_CR52_1_1*/
#ifdef START_CR52_1_2
    extern const uint32 __CORE_R52_1_2_START_ADDRESS;

    IP_MC_ME->PRTN2_CORE2_ADDR = (uint32)&__CORE_R52_1_2_START_ADDRESS;
#ifndef RTU1_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN2_CORE2_STAT & MC_ME_PRTN2_CORE2_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN2_CORE2_PCONF = 1;
        IP_MC_ME->PRTN2_CORE2_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN2_CORE2_STAT & MC_ME_PRTN2_CORE2_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[2].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_131_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[2].PSTAT_0 & MC_RGM_PRST_0_PERIPH_131_RST_MASK)
        ;
#endif /*START_CR52_1_2*/
#ifdef START_CR52_1_3
    extern const uint32 __CORE_R52_1_3_START_ADDRESS;

    IP_MC_ME->PRTN2_CORE3_ADDR = (uint32)&__CORE_R52_1_3_START_ADDRESS;
#ifndef RTU1_R52_LOCKSTEP_MODE
    if (!(IP_MC_ME->PRTN2_CORE2_STAT & MC_ME_PRTN2_CORE2_STAT_CCS_MASK)) {
        IP_MC_ME->PRTN2_CORE2_PCONF = 1;
        IP_MC_ME->PRTN2_CORE2_PUPD = 1;
        IP_MC_ME->CTL_KEY = 0x5AF0;
        IP_MC_ME->CTL_KEY = 0xA50F;
        while (!(IP_MC_ME->PRTN2_CORE2_STAT & MC_ME_PRTN2_CORE2_STAT_CCS_MASK)) { };
    }
#endif
    IP_MC_RGM->PRST_0[2].PRST_0 &= ~MC_RGM_PRST_0_PERIPH_132_RST_MASK;
    while (IP_MC_RGM->PSTAT_0[2].PSTAT_0 & MC_RGM_PRST_0_PERIPH_132_RST_MASK)
        ;
#endif /*START_CR52_1_3*/
#ifdef START_CM33_0
    extern const uint32_t __CORE_M33_0_START_ADDRESS;

    IP_MC_ME->PRTN0_CORE0_ADDR = (uint32)&__CORE_M33_0_START_ADDRESS;
    IP_MC_ME->PRTN0_CORE0_PCONF = 1;
    IP_MC_ME->PRTN0_CORE0_PUPD = 1;
    IP_MC_ME->CTL_KEY = 0x5AF0;
    IP_MC_ME->CTL_KEY = 0xA50F;
    while (!(IP_MC_ME->PRTN0_CORE0_STAT & MC_ME_PRTN0_CORE0_STAT_CCS_MASK)) { };
#endif /*START_CM33_0*/
}
#endif /* defined(START_CRxx) */
/*================================================================================================*/
/*
 * system initialization : system clock, interrupt router ...
 */
#ifdef __ICCARM__
#pragma default_function_attributes = @ ".systeminit"
#else
__attribute__ ((section (".systeminit")))
#endif

void SystemInit(void)
{
    uint32 i;
    uint32 coreMask;

/**************************************************************************/
/* DEFAULT MEMORY ENABLE*/
/**************************************************************************/
#ifdef MPU_ENABLE
    Core_MPU_Init();
#endif /*MPU_ENABLE*/

#if (defined(START_CR52_0_0) || defined(START_CR52_0_1) || defined(START_CR52_0_2) || \
    defined(START_CR52_0_3) || defined(START_CR52_1_0) || defined(START_CR52_1_1) ||  \
    defined(START_CR52_1_2) || defined(START_CR52_1_3) || defined(START_CM33_0))
    Sys_StartSecondaryCores();
#endif

    uint8 coreId = OsIf_GetCoreID();

    switch (coreId) {
        case RTU_0_R52_0:
        case RTU_0_R52_1:
        case RTU_0_R52_2:
        case RTU_0_R52_3:
            coreMask = (1UL << MSCM_IRSPRC_RTU0_GIC_SHIFT);
            break;
        case RTU_1_R52_0:
        case RTU_1_R52_1:
        case RTU_1_R52_2:
        case RTU_1_R52_3:
            coreMask = (1UL << MSCM_IRSPRC_RTU1_GIC_SHIFT);
            break;
        case SMU:
            coreMask = (1UL << MSCM_IRSPRC_SMU_CORE_SHIFT);
            break;
        default:
            coreMask = 0x0;
            break;
    }
    /* Only configure MSCM for RTU_0, RTU_1 and SMU */
    if (0u != coreMask) {
        /* Configure MSCM to enable/disable interrupts routing to Core processor */
        for (i = 0; i < MSCM_IRSPRC_COUNT; i++) {
            IP_MSCM->IRSPRC[i] |= (uint16)coreMask;
        }
    }

#if (defined(S32S2XX) || defined(S32E2XX))
    /* Enabling the DiPort signals for interrupts etc.*/
    DiPortSignalEnable();
#endif
    /**************************************************************************/
    /* Interrupt Controller ENABLE*/
    /**************************************************************************/
    Core_IC_Init();

    /**************************************************************************/
    /* FPU ENABLE*/
    /**************************************************************************/
    Core_FPU_Init();

    /**************************************************************************/
    /* ENABLE CACHE */
    /**************************************************************************/
    Core_Cache_Init();

#if (defined(S32S2XX) || defined(S32E2XX))
    /* Initialize AE SRAM */
    Sys_InitAeSram();

    DisableSvcProtection_AE();
#endif /* (defined(S32S2XX) || defined(S32E2XX)) */
}

#ifdef __ICCARM__
#pragma default_function_attributes =
#endif

#ifdef __cplusplus
}
#endif
