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
==================================================================================================*/
/*==================================================================================================
*   @file    core.c
*   @version 2.0.1
*
*   @brief   Platform - Startup Code.
*   @details Startup Code.
*            This file contains sample code only. It is not part of the production code deliverables
==================================================================================================*/
/**
 *   @implements core.c_Artifact
 */

#ifdef __cplusplus
extern "C" {
#endif

/*==================================================================================================
*                                         INCLUDE FILES
* 1) system and project includes
* 2) needed interfaces from external units
* 3) internal and external interfaces from this unit
==================================================================================================*/
#include "Platform_Types.h"
#include "Mcal.h"

#if (MCAL_PLATFORM_ARM != MCAL_ARM_RARCH)
#error R52-specific file included in compilation, but MCAL_PLATFORM_ARM != MCAL_ARM_RARCH. Double check the value of the Resource.ARM_CoreArchitecture configuration field.
#endif

#include "bsp_core.h"
// #include "gic500.h"
#ifdef S32E2XX
#include "S32E2_MSCM.h"
#else
#include "S32Z2_MSCM.h"
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
#define SCB_CCSIDR_ASSOCIATIVITY_Pos 3U       /*!< SCB CCSIDR: Associativity Position */
#define SCB_CCSIDR_ASSOCIATIVITY_Msk \
    (0x3FFUL << SCB_CCSIDR_ASSOCIATIVITY_Pos) /*!< SCB CCSIDR: Associativity Mask */

#define SCB_CCSIDR_NUMSETS_Pos 13U            /*!< SCB CCSIDR: NumSets Position */
#define SCB_CCSIDR_NUMSETS_Msk                                              \
    (0x7FFFUL << SCB_CCSIDR_NUMSETS_Pos)      /*!< SCB CCSIDR: NumSets Mask \
                                               */

#define SCB_DCISW_SET_Pos              6U     /*!< SCB DCISW: Set Position */
#define SCB_DCISW_SET_Msk              (0x7FUL << SCB_DCISW_SET_Pos) /*!< SCB DCISW: Set Mask */

#define SCB_DCISW_WAY_Pos              30U                           /*!< SCB DCISW: Way Position */
#define SCB_DCISW_WAY_Msk              (3UL << SCB_DCISW_WAY_Pos)    /*!< SCB DCISW: Way Mask */

#define SCB_CCR_IC_Pos                 12U /*!< SCB CCR: Instruction cache enable bit Position */
#define SCB_CCR_IC_Msk                 (1UL << SCB_CCR_IC_Pos) /*!< SCB CCR: Instruction cache enable bit Mask */

#define SCB_CCR_DC_Pos                 2U /*!< SCB CCR: Cache enable bit Position */
#define SCB_CCR_DC_Msk                 (1UL << SCB_CCR_DC_Pos) /*!< SCB CCR: Cache enable bit Mask */

#define CCSIDR_WAYS(x)                 (((x) & SCB_CCSIDR_ASSOCIATIVITY_Msk) >> SCB_CCSIDR_ASSOCIATIVITY_Pos)
#define CCSIDR_SETS(x)                 (((x) & SCB_CCSIDR_NUMSETS_Msk) >> SCB_CCSIDR_NUMSETS_Pos)

#define S32_SCB_CPACR_CPx_MASK(CpNum)  (0x3U << S32_SCB_CPACR_CPx_SHIFT(CpNum))
#define S32_SCB_CPACR_CPx_SHIFT(CpNum) (2U * ((uint32)CpNum))
#define S32_SCB_CPACR_CPx(CpNum, x)                                  \
    (((uint32)(((uint32)(x)) << S32_SCB_CPACR_CPx_SHIFT((CpNum)))) & \
        S32_SCB_CPACR_CPx_MASK((CpNum)))

#define S32_SCB_CPACR_ASEDIS_SHIFT 30U
#define S32_SCB_CPACR_ASEDIS_MASK  (1UL << S32_SCB_CPACR_ASEDIS_SHIFT)

#define S32_SCB_FPEXC_EN_SHIFT     30U
#define S32_SCB_FPEXC_EN_MASK      (1UL << S32_SCB_FPEXC_EN_SHIFT)
#define S32_SCB_FPEXC_DIS_MASK     (1UL << S32_SCB_FPEXC_EN_SHIFT)

#define S32_MPU_CTRL_ENABLE_MASK   1U

#define S32_CACHE_WAY_TOTAL        4U  /*!< CACHE WAY TOTAL: Total number of the ways */
#define S32_CSCTLR_FLW_MASK        7UL /*!< CSCTLR FLW: Bit mask for both IFLW and DFLW */

#define S32_CSCTLR_IFLW_SHIFT      8U  /*!< CSCTLR IFLW: IFLW position */
#define S32_CSCTLR_IFLW_MASK \
    (S32_CSCTLR_FLW_MASK << S32_CSCTLR_IFLW_SHIFT) /*!< CSCTLR IFLW: IFLW Mask */

#define S32_CSCTLR_DFLW_SHIFT 0U                   /*!< CSCTLR DFLW: DFLW position */
#define S32_CSCTLR_DFLW_MASK \
    (S32_CSCTLR_FLW_MASK << S32_CSCTLR_DFLW_SHIFT) /*!< CSCTLR DFLW: DFLW Mask */

#define S32_CSCTLR_IFLW(x) \
    (((uint32)(((uint32)(x)) << S32_CSCTLR_IFLW_SHIFT)) & S32_CSCTLR_IFLW_MASK)
#define S32_CSCTLR_DFLW(x) \
    (((uint32)(((uint32)(x)) << S32_CSCTLR_DFLW_SHIFT)) & S32_CSCTLR_DFLW_MASK)

/*==================================================================================================
*                                       LOCAL MACROS
==================================================================================================*/
#define GIC0_DISTRIBUTOR_BASEADDR       ((uint32)0x47800000UL)
#define CPU_DUMMY_BASEADDR              ((uint32)0x0UL)
#define GIC0_REDISTRIBUTOR_CONTROL0     ((uint32)0x47800000UL)
#define GICD_ICFGR_HIGH_LEVEL_SENSITIVE ((uint32)0U)
#define CORE_R52_SCTLR_TE_MASK          (0x40000000UL)
#define CORE_R52_SCTLR_TE_SHIFT         (30UL)
#define CORE_R52_SCTLR_TE(x) \
    (((uint32)(((uint32)(x)) << CORE_R52_SCTLR_TE_SHIFT)) & ~CORE_R52_SCTLR_TE_MASK)
#define SET_T32_MODE (1U)
/* Cache way config set for D-cache and I-cache*/
#define CACHE_WAYS_CFG_0 \
    ((uint8)0U) /* 0 ways allocated to FLS_INTERFACE, 4 ways allocated to AXIM */
#define CACHE_WAYS_CFG_1 \
    ((uint8)1U) /* 1 ways allocated to FLS_INTERFACE, 3 ways allocated to AXIM */
#define CACHE_WAYS_CFG_2 \
    ((uint8)2U) /* 2 ways allocated to FLS_INTERFACE, 2 ways allocated to AXIM */
#define CACHE_WAYS_CFG_3 \
    ((uint8)3U) /* 3 ways allocated to FLS_INTERFACE, 1 ways allocated to AXIM */
#define CACHE_WAYS_CFG_4 \
    ((uint8)4U) /* 4 ways allocated to FLS_INTERFACE, 0 ways allocated to AXIM */

#define S32_MPU_DEVICE_nGnRnE                             (0x00U)
#define S32_MPU_DEVICE_nGnRE                              (0x04U)
#define S32_MPU_DEVICE_nGRE                               (0x08U)
#define S32_MPU_DEVICE_GRE                                (0x0CU)
#define S32_MPU_OUTER_WT_NO_TRANS_INNER_NO_CACHE          (0x84U)
#define S32_MPU_OUTER_WB_TRANS_WA_RA_INNER_WB_TRANS_WA_RA (0xFFU)
#define S32_MPU_OUTER_NO_CACHE_INNER_NO_CACHE             (0x44U)

#define S32_MPU_MAIR0_INDEX_0_SHIFT                       (0)
#define S32_MPU_MAIR0_INDEX_1_SHIFT                       (8)
#define S32_MPU_MAIR0_INDEX_2_SHIFT                       (16)
#define S32_MPU_MAIR0_INDEX_3_SHIFT                       (24)
#define S32_MPU_MAIR1_INDEX_4_SHIFT                       (0)
#define S32_MPU_MAIR1_INDEX_5_SHIFT                       (8)
#define S32_MPU_MAIR1_INDEX_6_SHIFT                       (16)
#define S32_MPU_MAIR1_INDEX_7_SHIFT                       (24)
/*==================================================================================================
*                                       LOCAL VARIABLES
==================================================================================================*/
#define CPU_DEFAULT_MEMORY_CNT                            (19U)
#define S32_MPU_MAIR_COUNT                                (2U)

/* Memory Attribute Indirection Registers 0 and
   0-1: 0x00 - Device-nGnRnE (Corresponds to Strongly-ordered in ARMv7)
   2  : 0x84 - Normal Memory, Outer Write-Throught Non-transient, Inner Non-cacheable
   3  : 0x00 - Device-nGnRnE (Corresponds to Strongly-ordered in ARMv7)
   4  : 0xFF - Normal Memory, Inner/Outer Write-Back non-transient, Read/Write Allocate
   5  : 0x44 - Normal Memory, Inner/Outer Non-Cacheable
   6  : 0x04 - Device-nGnRE (Corresponds to Device in ARMv7)
   7  : 0x0C - Device-GRE (Similar to Normal noncacheable, but does not permit speculative accesses)
*/
/* Attr2 of MAIR0 is used to configure MPU for LPDDR4 region (No Inner cache & Outer Write-Through
 * non-transient). But in the default MPU configuration, only apply MPU configuration to derivatives
 * without LPDDR4.
 *
 * The rule when we intialize MPU is memory need to be stable before apply protection layer.
 * LPDDR4 is optional so we cannot make sure LPDDR4 is available or not.
 * Default MPU configuration region for LPDDR should be set to not allow access or strong order
 * (nGnRnE) to avoid spectaculative/early access. So in case user need to enable protection for
 * LPDDR4, please use PLATFORM feature to re-apply new configuration for LPDDR4 region, see example:
 * Platform_Ip_DDR_INIT_S32E2XX
 *
 * Need to call Platform API to configure again DDR region for using DDR features (Apply Attr2 of
 * MAIR0 for DDR region)
 */

#ifndef MULTIPLE_IMAGE
#ifndef CLUSTER1
/*
  Linker reference: linker_ram_r52
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU0 TCMs 0x30000000  0x30FFFFFF       16384  Normal
None                  None                  No           Yes           Read/Write Read/Write 1  SRAM
+ STACK                                   0x31780000  0x31800000         512  Normal
Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write Read/Write 2  SRAM
NC                                        0x31800000  0x3183FFFF         256  Normal            None
None                  Outer        Yes           Read/Write           Read/Write 3  SRAM SHARED
0x31840000  0x3187FFFF         256  Normal            None                  None Inner        No
Read/Write           Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x79900000
0x7BFFFFFF       39936  Normal            Write-Back/Allocate   Write-Back/Allocate   Outer Yes
Read-only            Read-only 5  LOCAL CRAM-M                                   0x32100000
0x327FFFFF        7168  Normal            Write-Back/Allocate   Write-Back/Allocate   Outer Yes
Read/Write           Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000
0x475FFFFF      120832  Device            None                  None                  Outer No
Read/Write           Read/Write 7  RTU0 GIC                                       0x47800000
0x479FFFFF        2048  Strongly Ordered  None                  None                  Outer No
Read/Write           Read/Write 8  STM-500 Peripheral                             0x48000000
0x4BFFFFFF       65536  Device            None                  None                  Outer No
Read/Write           Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000
0x76FFFFFF       24576  Device            None                  None                  Outer No
Read/Write           Read/Write 10  R0/1-LPDDR4                                    0x80000000
0xFFFFFFFF         2GB  Strongly Ordered  None                  None                  Outer Yes
Read/Write           Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative
access on this area before it is stable enough for early access. User can change it to another
attribute if they ensure no harm for speculative access. 11  FlexLLCE CRAM 0x1F000000  0x1F03FFFF
256  Device            None                  None                  Outer        Yes Read/Write
Read/Write 12  FlexLLCE DRAM                                  0x26000000  0x260BBFFF         752
Device            None                  None                  Outer        Yes           Read/Write
Read/Write 13  QuadSPI AHB                                    0x00000000  0x17FFFFFF      393216
Device            None                  None                  Outer        Yes           Read/Write
Read/Write 14  AE FLASH                                       0x4E000000  0x4E3FFFFF        4096
Device-nGnRE      None                  None                  Outer        Yes           Read/Write
Read/Write Note: AE FLASH should have Write access permission due to erase interlock write mechanism
in C55FP. 15  AE SRAM                                        0x4E400000  0x4E5FFFFF        2048
Device-nGnRE      None                  None                  Outer        Yes           Read/Write
Read/Write 16  AE Peripheral + UTEST                          0x4E600000  0x4EFFFFFF       10240
Device-nGnRE      None                  None                  Outer        No            Read/Write
Read/Write 17  SMU System shared Sram                         0x250FC000  0x250FFFFF          16
Normal            None                  None                  Outer        No            Read/Write
Read/Write 18  CE System shared Sram                          0x260BC000  0x260BFFFF          16
Normal            None                  None                  Outer        No            Read/Write
Read/Write
*/
// static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = {0x30000002UL, 0x31780002UL, 0x31800012UL,
// 0x3184001BUL, 0x79900016UL, 0x32100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL, 0x70000013UL,
// 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000012UL, 0x4E400012UL, 0x4E600013UL,
// 0x250FC013UL, 0x260BC013UL}; static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = {0x30FFFFCBUL,
// 0x317FFFC9UL, 0x3183FFCBUL, 0x3187FFCBUL, 0x7BFFFFC9UL, 0x327FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL,
// 0x4BFFFFCDUL, 0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
// 0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL};

#else
/*
  Linker reference: linker_ram_r52_rtu1
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU1 TCMs 0x34000000  0x34FFFFFF       16384  Normal
None                  None                  No           Yes           Read/Write Read/Write 1  SRAM
+ STACK                                   0x35780000  0x357FFFFF         512  Normal
Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write Read/Write 2  SRAM
NC                                        0x35800000  0x3583FFFF         256  Normal            None
None                  Outer        Yes           Read/Write           Read/Write 3  SRAM SHARED
0x35840000  0x3587FFFF         256  Normal            None                  None Inner        No
Read/Write           Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x7D900000
0x7FFFFFFF       39936  Normal            Write-Back/Allocate   Write-Back/Allocate   Outer Yes
Read-only            Read-only 5  LOCAL CRAM-M                                   0x36100000
0x367FFFFF        7168  Normal            Write-Back/Allocate   Write-Back/Allocate   Outer Yes
Read/Write           Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000
0x475FFFFF      120832  Device            None                  None                  Outer No
Read/Write           Read/Write 7  RTU1 GIC                                       0x47800000
0x479FFFFF        2048  Strongly Ordered  None                  None                  Outer No
Read/Write           Read/Write 8  STM-500 Peripheral                             0x48000000
0x4BFFFFFF       65536  Device            None                  None                  Outer No
Read/Write           Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000
0x76FFFFFF       24576  Device            None                  None                  Outer No
Read/Write           Read/Write 10  R0/1-LPDDR4                                    0x80000000
0xFFFFFFFF         2GB  Strongly Ordered  None                  None                  Outer Yes
Read/Write           Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative
access on this area before it is stable enough for early access. User can change it to another
attribute if they ensure no harm for speculative access. 11  FlexLLCE CRAM 0x1F000000  0x1F03FFFF
256  Device            None                  None                  Outer        Yes Read/Write
Read/Write 12  FlexLLCE DRAM                                  0x26000000  0x260BBFFF         752
Device            None                  None                  Outer        Yes           Read/Write
Read/Write 13  QuadSPI AHB                                    0x00000000  0x17FFFFFF      393216
Device            None                  None                  Outer        Yes           Read/Write
Read/Write 14  AE FLASH                                       0x4E000000  0x4E3FFFFF        4096
Device-nGnRE      None                  None                  Outer        Yes           Read/Write
Read/Write Note: AE FLASH should have Write access permission due to erase interlock write mechanism
in C55FP. 15  AE SRAM                                        0x4E400000  0x4E5FFFFF        2048
Device-nGnRE      None                  None                  Outer        Yes           Read/Write
Read/Write 16  AE Peripheral + UTEST                          0x4E600000  0x4EFFFFFF       10240
Device-nGnRE      None                  None                  Outer        No            Read/Write
Read/Write 17  SMU System shared Sram                         0x250FC000  0x250FFFFF          16
Normal            None                  None                  Outer        No            Read/Write
Read/Write 18  CE System shared Sram                          0x260BC000  0x260BFFFF          16
Normal            None                  None                  Outer        No            Read/Write
Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x34000002UL, 0x35780002UL, 0x35800012UL,
    0x3584001BUL, 0x7D900012UL, 0x36100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000012UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x34FFFFCBUL, 0x357FFFC9UL, 0x3583FFCBUL,
    0x3587FFCBUL, 0x7FFFFFC9UL, 0x367FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#endif
#else
#ifdef CORE_R52_0_0
/*
  Linker reference: linker_ram_r52_c0_0
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU0_R52_0_TCMS 0x30000000  0x302FFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x31780000  0x317FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x31800000  0x3183FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x31840000  0x3187FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x79900000  0x7BFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x32100000  0x327FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU0 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x30000002UL, 0x31780002UL, 0x31800012UL,
    0x3184001BUL, 0x79900012UL, 0x32100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x302FFFCBUL, 0x317FFFC9UL, 0x3183FFCBUL,
    0x3187FFCBUL, 0x7BFFFFC9UL, 0x327FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_0_1)
/*
  Linker reference: linker_ram_r52_c0_1
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU0_R52_1_TCMS 0x30400000  0x306FFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x31780000  0x317FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x31800000  0x3183FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x31840000  0x3187FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x79900000  0x7BFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x32100000  0x327FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU0 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x30400002UL, 0x31780002UL, 0x31800012UL,
    0x3184001BUL, 0x79900012UL, 0x32100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x306FFFCBUL, 0x317FFFC9UL, 0x3183FFCBUL,
    0x3187FFCBUL, 0x7BFFFFC9UL, 0x327FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_0_2)
/*
  Linker reference: linker_ram_r52_c0_2
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU0_R52_2_TCMS 0x30800000  0x30AFFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x31780000  0x317FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x31800000  0x3183FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x31840000  0x3187FFFF         256
Normal            None                  None                  Inner        Yes           Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x79900000  0x7BFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x32100000  0x327FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU0 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x30800002UL, 0x31780002UL, 0x31800012UL,
    0x3184001BUL, 0x79900012UL, 0x32100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x30AFFFCBUL, 0x317FFFC9UL, 0x3183FFCBUL,
    0x3187FFCBUL, 0x7BFFFFC9UL, 0x327FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_0_3)
/*
  Linker reference: linker_ram_r52_c0_3
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU0_R52_3_TCMS 0x30C00000  0x30EFFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x31780000  0x317FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x31800000  0x3183FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x31840000  0x3187FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x79900000  0x7BFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x32100000  0x327FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU0 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x30C00002UL, 0x31780002UL, 0x31800012UL,
    0x3184001BUL, 0x79900012UL, 0x32100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x30EFFFCBUL, 0x317FFFC9UL, 0x3183FFCBUL,
    0x3187FFCBUL, 0x7BFFFFC9UL, 0x327FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_1_0)
/*
  Linker reference: linker_ram_r52_c1_0
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU1_R52_0_TCMS 0x34000000  0x342FFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x35780000  0x357FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x35800000  0x3583FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x35840000  0x3587FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x7D900000  0x7FFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x36100000  0x367FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU1 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x34000002UL, 0x35780002UL, 0x35800012UL,
    0x3584001BUL, 0x7D900012UL, 0x36100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x342FFFCBUL, 0x357FFFC9UL, 0x3583FFCBUL,
    0x3587FFCBUL, 0x7FFFFFC9UL, 0x367FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_1_1)
/*
  Linker reference: linker_ram_r52_c1_1
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU1_R52_1_TCMS 0x34400000  0x346FFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x35780000  0x357FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x35800000  0x3583FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x35840000  0x3587FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x7D900000  0x7FFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x36100000  0x367FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU1 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x34400002UL, 0x35780002UL, 0x35800012UL,
    0x3584001BUL, 0x7D900012UL, 0x36100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x346FFFCBUL, 0x357FFFC9UL, 0x3583FFCBUL,
    0x3587FFCBUL, 0x7FFFFFC9UL, 0x367FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_1_2)
/*
  Linker reference: linker_ram_r52_c1_2
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU1_R52_2_TCMS 0x34800000  0x34AFFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x35780000  0x357FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x35800000  0x3583FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x35840000  0x3587FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x7D900000  0x7FFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x36100000  0x367FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU1 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x34800002UL, 0x35780002UL, 0x35800012UL,
    0x3584001BUL, 0x7D900012UL, 0x36100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x34AFFFCBUL, 0x357FFFC9UL, 0x3583FFCBUL,
    0x3587FFCBUL, 0x7FFFFFC9UL, 0x367FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };

#elif defined(CORE_R52_1_3)
/*
  Linker reference: linker_ram_r52_c1_3
  Region  Description                                    Start       End           Size[KB]  Type
Inner Cache Policy    Outer Cache Policy    Shareable    Executable    Privileged Access
Unprivileged Access
--------  ---------------------------------------------- ----------  ----------  ----------
----------------  --------------------  --------------------  -----------  ------------
-------------------  --------------------- 0  RTU1_R52_3_TCMS 0x34C00000  0x34EFFFFF        3072
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 1  SRAM + STACK                                   0x35780000  0x357FFFFF         512
Normal            Write-Back/Allocate   Write-Back/Allocate   No           Yes           Read/Write
Read/Write 2  SRAM NC                                        0x35800000  0x3583FFFF         256
Normal            None                  None                  Outer        Yes           Read/Write
Read/Write 3  SRAM SHARED                                    0x35840000  0x3587FFFF         256
Normal            None                  None                  Inner        No            Read/Write
Read/Write 4  LOCAL CRAM-F + DDRWindow-F                     0x7D900000  0x7FFFFFFF       39936
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read-only
Read-only 5  LOCAL CRAM-M                                   0x36100000  0x367FFFFF        7168
Normal            Write-Back/Allocate   Write-Back/Allocate   Outer        Yes           Read/Write
Read/Write 6  P0-P6+CE+SMU+AES+CANXL                         0x40000000  0x475FFFFF      120832
Device            None                  None                  Outer        No            Read/Write
Read/Write 7  RTU1 GIC                                       0x47800000  0x479FFFFF        2048
Strongly Ordered  None                  None                  Outer        No            Read/Write
Read/Write 8  STM-500 Peripheral                             0x48000000  0x4BFFFFFF       65536
Device            None                  None                  Outer        No            Read/Write
Read/Write 9  QSPI_Rx+LPDDRPHY+GTM+NETC+NIC+R0/1 Peripherals 0x70000000  0x76FFFFFF       24576
Device            None                  None                  Outer        No            Read/Write
Read/Write 10  R0/1-LPDDR4                                    0x80000000  0xFFFFFFFF         2GB
Strongly Ordered  None                  None                  Outer        Yes           Read/Write
Read/Write Note: R0/1-LPDDR4 is set to strongly ordered to avoid speculative access on this area
before it is stable enough for early access. User can change it to another attribute if they ensure
no harm for speculative access. 11  FlexLLCE CRAM                                  0x1F000000
0x1F03FFFF         256  Device            None                  None                  Outer Yes
Read/Write           Read/Write 12  FlexLLCE DRAM                                  0x26000000
0x260BBFFF         752  Device            None                  None                  Outer Yes
Read/Write           Read/Write 13  QuadSPI AHB                                    0x00000000
0x17FFFFFF      393216  Device            None                  None                  Outer Yes
Read/Write           Read/Write 14  AE FLASH                                       0x4E000000
0x4E3FFFFF        4096  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write Note: AE FLASH should have Write access permission due to erase
interlock write mechanism in C55FP. 15  AE SRAM                                        0x4E400000
0x4E5FFFFF        2048  Device-nGnRE      None                  None                  Outer Yes
Read/Write           Read/Write 16  AE Peripheral + UTEST                          0x4E600000
0x4EFFFFFF       10240  Device-nGnRE      None                  None                  Outer No
Read/Write           Read/Write 17  SMU System shared Sram                         0x250FC000
0x250FFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write 18  CE System shared Sram                          0x260BC000
0x260BFFFF          16  Normal            None                  None                  Outer No
Read/Write           Read/Write
*/
static const uint32 rbar[CPU_DEFAULT_MEMORY_CNT] = { 0x34C00002UL, 0x35780002UL, 0x35800012UL,
    0x3584001BUL, 0x7D900012UL, 0x36100012UL, 0x40000013UL, 0x47800013UL, 0x48000013UL,
    0x70000013UL, 0x80000012UL, 0x1F000012UL, 0x26000012UL, 0x00000012UL, 0x4E000016UL,
    0x4E400012UL, 0x4E600013UL, 0x250FC013UL, 0x260BC013UL };
static const uint32 rlar[CPU_DEFAULT_MEMORY_CNT] = { 0x34EFFFCBUL, 0x357FFFC9UL, 0x3583FFCBUL,
    0x3587FFCBUL, 0x7FFFFFC9UL, 0x367FFFC9UL, 0x475FFFCDUL, 0x479FFFC1UL, 0x4BFFFFCDUL,
    0x76FFFFCDUL, 0xFFFFFFC1UL, 0x1F03FFCDUL, 0x260BBFCDUL, 0x17FFFFCDUL, 0x4E3FFFCDUL,
    0x4E5FFFCDUL, 0x4EFFFFCDUL, 0x250FFFEBUL, 0x260BFFEBUL };
#endif
#endif

/*==================================================================================================-
*                                       GLOBAL CONSTANTS
==================================================================================================*/

/*==================================================================================================
*                                       GLOBAL VARIABLES
==================================================================================================*/
extern uint32 R52VtabeRefArray[];

/*==================================================================================================
*                                   LOCAL FUNCTION PROTOTYPES
==================================================================================================*/

/*==================================================================================================
*                                       LOCAL FUNCTIONS
==================================================================================================*/
/* Assembly functions */
uint32 read_CPACR(void);
void write_CPACR(uint32);
void write_FPEXC(uint32);
uint32 read_SCTLR(void);
void write_SCTLR(uint32);
void write_ICIALLU(uint32);
uint32 read_CCSIDR(void);
void write_DCISW(uint32);
uint32 read_CSSELR(void);
void write_CSSELR(uint32);
void write_PRSELR(uint32);
void write_PRBAR(uint32);
void write_PRLAR(uint32);
void write_MAIR0(uint32);
void write_MAIR1(uint32);
void write_IMP_CSCTLR(uint32);

/*==================================================================================================
*                                       GLOBAL FUNCTIONS
==================================================================================================*/
#ifdef MCAL_ENABLE_USER_MODE_SUPPORT

/*================================================================================================*/
/**
 * @brief Core_SuspendInterrupts
 * @details Suspend Interrupts
 */
/*================================================================================================*/
void Core_SuspendInterrupts(void)
{
    /*to do after EL0 is instroduced */
}
/*================================================================================================*/
/**
 * @brief Core_ResumeInterrupts
 * @details Resume Interrupts
 */
/*================================================================================================*/
void Core_ResumeInterrupts(void)
{
    /*to do after EL0 is instroduced */
}
#endif /* MCAL_ENABLE_USER_MODE_SUPPORT */

/*================================================================================================*/
/**
 * @brief Core_EL1SuspendInterrupts
 * @details Suspend Interrupts
 */
/*================================================================================================*/
void Core_EL1SuspendInterrupts(void)
{
    uint32_t cpsr_val = 0;
    /*LDRA_NOANALYSIS*/
    ASM_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val));  /* get current cpsr */
                                                     /*LDRA_ANALYSIS*/
    cpsr_val |= 0xC0;                                /* set the I and F bit (bit7) */
                                                     /*LDRA_NOANALYSIS*/
    ASM_KEYWORD("msr cpsr, %0\n" : : "r"(cpsr_val)); /* writeback modified value */
                                                     /*LDRA_ANALYSIS*/
    return;
}
/*================================================================================================*/
/**
 * @brief Core_ResumeInterrupts
 * @details Resume Interrupts
 */
/*================================================================================================*/
void Core_EL1ResumeInterrupts(void)
{
    uint32_t cpsr_val = 0;
    /*LDRA_NOANALYSIS*/
    ASM_KEYWORD("mrs %0, cpsr\n" : "=r"(cpsr_val));  /* get current cpsr */
                                                     /*LDRA_ANALYSIS*/
    cpsr_val &= (uint32_t)~0xC0;                     /* clear the I and F bit (bit7) */
                                                     /*LDRA_NOANALYSIS*/
    ASM_KEYWORD("msr cpsr, %0\n" : : "r"(cpsr_val)); /* writeback modified value */
                                                     /*LDRA_ANALYSIS*/
    return;
}

/*================================================================================================*/
/**
 * @brief Core_disableIsrSource
 * @details Disable Interrupt Source
 */
/*================================================================================================*/
void Core_disableIsrSource(uint16 id)
{
    (void)id;
    // gic500_disableIntID(id);
}

/*================================================================================================*/
/**
 * @brief Core_enableIsrSource
 * @details Enable Interrupt Source
 */
/*================================================================================================*/
void Core_enableIsrSource(uint16 id, uint8 prio)
{
    (void)prio;
    (void)id;
    // gic500_setIntPriority(id, prio);
    // gic500_enableIntID(id);
}

/*================================================================================================*/
/**
 * @brief Core_registerIsrHandler
 * @details Register the interrupt handler
 */
/*================================================================================================*/
void Core_registerIsrHandler(uint16 irq_id, void (*isr_handler)(void))
{
    (void)irq_id;
    (void)isr_handler;
    // #ifdef RTU_R52
    //     uint32 coreId = IP_MSCM->CPXNUM;
    //     uint32 *pVectorRam = (uint32 *)R52VtabeRefArray[coreId%4];
    // #else
    //     uint32 *pVectorRam = (uint32 *)R52VtabeRefArray;
    // #endif

    //     /* Set handler into vector table */
    //     pVectorRam[irq_id] = (uint32)isr_handler;

    // /*LDRA_NOANALYSIS*/
    //     MCAL_INSTRUCTION_SYNC_BARRIER();
    //     MCAL_DATA_SYNC_BARRIER();
    // /*LDRA_ANALYSIS*/
}

/*================================================================================================*/
/**
 * @brief        Core_Cache_Segregation
 * @details      Controls segregation of instruction and data cache ways between Flash and AXIM.
 *               This fuction must be called before enable cache.
 * @param[in]    icache_config: Config set for I-cache.
 * @param[in]    dcache_config: Config set for D-cache.
 *
 * @return
 */
/*================================================================================================*/
// static void Core_Cache_Segregation (uint8 icache_config, uint8 dcache_config)
// {
//     uint32 control_reg=0;
//     control_reg = S32_CSCTLR_IFLW(icache_config) | S32_CSCTLR_DFLW(dcache_config);
//     write_IMP_CSCTLR(control_reg);
// }

/*================================================================================================*/
/**
 * @brief Core_IC_Init
 * @details Initialize the exception that is taken in the T32 mode.
 */
/*================================================================================================*/
__attribute__((section(".systeminit"))) void Core_IC_Init(void)
{
    /* Enable exception to take into T32 mode */
    // write_SCTLR((read_SCTLR() & ~CORE_R52_SCTLR_TE_MASK)|(SET_T32_MODE <<
    // CORE_R52_SCTLR_TE_SHIFT)); gic500_enableDistributor(); gic500_enableRedistributor();
    // gic500_enableCpuInterface();
}

/*================================================================================================*/
/**
 * @brief Core_FPU_Init
 * @details Initialize FPU features.
 */
/*================================================================================================*/
__attribute__((section(".systeminit"))) void Core_FPU_Init(void)
{
#ifdef ENABLE_FPU
    uint32 cpacr;

    cpacr = read_CPACR();
    cpacr |= (S32_SCB_CPACR_CPx(10U, 3U) | S32_SCB_CPACR_CPx(11U, 3U));
    cpacr &= ~S32_SCB_CPACR_ASEDIS_MASK;
    write_CPACR(cpacr);

    ASM_KEYWORD("isb");                 /* Ensure side-effect of CPACR is visible */

    write_FPEXC(S32_SCB_FPEXC_EN_MASK); /* Enable VFP and SIMD extensions */

    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
#endif
}

/*================================================================================================*/
/**
 * @brief Core_FPU_DeInit
 * @details De-Initialize FPU features.
 */
/*================================================================================================*/
void Core_FPU_DeInit(void);
__attribute__((section(".systeminit"))) void Core_FPU_DeInit(void)
{
#ifdef ENABLE_FPU
    uint32 cpacr;

    cpacr = read_CPACR();
    cpacr &= ~(S32_SCB_CPACR_CPx(10U, 3U) | S32_SCB_CPACR_CPx(11U, 3U));
    cpacr &= ~S32_SCB_CPACR_ASEDIS_MASK;
    write_CPACR(cpacr);

    ASM_KEYWORD("isb");                  /* Ensure side-effect of CPACR is visible */

    write_FPEXC(S32_SCB_FPEXC_DIS_MASK); /* Disable VFP and SIMD extensions */

    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
#endif
}

/*================================================================================================*/
/**
 * @brief Core_MPU_Init
 * @details Initialize MPU features.
 */
/*================================================================================================*/
// __attribute__ ((section (".systeminit")))
// void Core_MPU_Init(void)
// {
// #ifndef SIM_TYPE_VDK
//     uint32 counter;

//     ASM_KEYWORD("dsb");
//     ASM_KEYWORD("isb");

//     if (0 < S32_MPU_MAIR_COUNT)
//     {
//         write_MAIR0(mair[0U]);
//     }

//     if (1 < S32_MPU_MAIR_COUNT)
//     {
//         write_MAIR1(mair[1U]);
//     }

//     for (counter = 0U; counter < CPU_DEFAULT_MEMORY_CNT; counter++)
//     {
//         write_PRSELR(counter);
//         write_PRBAR(rbar[counter]);
//         write_PRLAR(rlar[counter]);
//     }

//     /* Enable MPU */
//     write_SCTLR(read_SCTLR() | S32_MPU_CTRL_ENABLE_MASK);

//     ASM_KEYWORD("dsb");
//     ASM_KEYWORD("isb");
// #endif
// }

/*================================================================================================*/
/**
 * @brief Core_Cache_Init
 * @details Initialize Cache features.
 */
/*================================================================================================*/
__attribute__((section(".systeminit"))) void Core_Cache_Init(void)
{
    /* If the Cortex-R52 processor has been built with instruction or data caches,
       they are automatically invalidated before they are used by the processor,
       unless CFGL1CACHEINVDISx is tied HIGH */
    /* TBD: Check if we can skip the invalidation */
    // uint32 ccsidr = 0U;
    // uint32 sets   = 0U;
    // uint32 ways   = 0U;
#if ((defined D_CACHE_ENABLE) || (defined I_CACHE_ENABLE))
    /* Segregation cache ways, For I-CACHE: Flash ways is 4, AXIM is 0 .
                               For D_CACHE: Flash ways is 0, AXIM is 4*/
    Core_Cache_Segregation(CACHE_WAYS_CFG_4, CACHE_WAYS_CFG_0);
#endif
#ifdef D_CACHE_ENABLE
    /*init Data caches*/
    write_CSSELR(0U); /* select Level 1 data cache */
    ASM_KEYWORD("dsb");
    ccsidr = read_CCSIDR();
    sets = (uint32)(CCSIDR_SETS(ccsidr));
    do {
        ways = (uint32)(CCSIDR_WAYS(ccsidr));
        do {
            write_DCISW(((sets << SCB_DCISW_SET_Pos) & SCB_DCISW_SET_Msk) |
                ((ways << SCB_DCISW_WAY_Pos) & SCB_DCISW_WAY_Msk));
            ASM_KEYWORD("dsb");
        } while (ways-- != 0U);
    } while (sets-- != 0U);
    ASM_KEYWORD("dsb");
    write_SCTLR(read_SCTLR() | (uint32)SCB_CCR_DC_Msk); /* enable D-Cache */
    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
#endif

#ifdef I_CACHE_ENABLE
    /*init Code caches*/
    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
    write_ICIALLU(0U);                                  /* invalidate I-Cache */
    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
    write_SCTLR(read_SCTLR() | (uint32)SCB_CCR_IC_Msk); /* enable I-Cache */
    ASM_KEYWORD("dsb");
    ASM_KEYWORD("isb");
#endif
}

#ifdef __cplusplus
}
#endif
