/*==================================================================================================
*   Project              : RTD AUTOSAR 4.7
*   Platform             : CORTEXM
*   Peripheral           : SIUL2
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
*   used strictly in accordance with the applicable license terms. By expressly
*   accepting such terms or by downloading, installing, activating and/or otherwise
*   using the software, you are agreeing that you have read, and that you agree to
*   comply with and are bound by, such license terms. If you do not agree to be
*   bound by the applicable license terms, then you may not retain, install,
*   activate or otherwise use the software.
==================================================================================================*/

#ifndef SIUL2_PORT_IP_TRUSTEDFUNCTIONS_H
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_H

/**
 *   @file Siul2_Port_Ip_TrustedFunctions.h
 *
 *   @addtogroup Port_IPL Port IPL
 *   @{
 */

#ifdef __cplusplus
extern "C" {
#endif

#include "Std_Types.h"
#include "Siul2_Port_Ip_Types.h"
#include "Port_Cfg.h"

/*==================================================================================================
*                              SOURCE FILE VERSION INFORMATION
==================================================================================================*/
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_VENDOR_ID_H                   43
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MAJOR_VERSION_H    4
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MINOR_VERSION_H    7
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_REVISION_VERSION_H 0
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MAJOR_VERSION_H            2
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MINOR_VERSION_H            0
#define SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_PATCH_VERSION_H            1

/*==================================================================================================
*                                     FILE VERSION CHECKS
==================================================================================================*/
#ifndef DISABLE_MCAL_INTERMODULE_ASR_CHECK
/* Check if Siul2_Port_Ip_TrustedFunctions.h and Std_Types.h file are of the same Autosar version */
#if ((SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MAJOR_VERSION_H != STD_AR_RELEASE_MAJOR_VERSION) || \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MINOR_VERSION_H != STD_AR_RELEASE_MINOR_VERSION))
#error "AutoSar Version Numbers of Siul2_Port_Ip_TrustedFunctions.h and Std_Types.h are different"
#endif
#endif

/* Check if the files Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h are of the same
 * version */
#if (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_VENDOR_ID_H != SIUL2_PORT_IP_TYPES_VENDOR_ID_H)
#error "Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h have different vendor ids"
#endif

/* Check if Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h are of the same Autosar
 * version */
#if ((SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MAJOR_VERSION_H !=   \
         SIUL2_PORT_IP_TYPES_AR_RELEASE_MAJOR_VERSION_H) ||          \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MINOR_VERSION_H !=    \
        SIUL2_PORT_IP_TYPES_AR_RELEASE_MINOR_VERSION_H) ||           \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_REVISION_VERSION_H != \
        SIUL2_PORT_IP_TYPES_AR_RELEASE_REVISION_VERSION_H))
#error \
    "AutoSar Version Numbers of Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h are different"
#endif

/* Check if Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h are of the same Software
 * version */
#if ((SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MAJOR_VERSION_H != \
         SIUL2_PORT_IP_TYPES_SW_MAJOR_VERSION_H) ||        \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MINOR_VERSION_H !=  \
        SIUL2_PORT_IP_TYPES_SW_MINOR_VERSION_H) ||         \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_PATCH_VERSION_H != SIUL2_PORT_IP_TYPES_SW_PATCH_VERSION_H))
#error \
    "Software Version Numbers of Siul2_Port_Ip_TrustedFunctions.h and Siul2_Port_Ip_Types.h are different"
#endif

/* Check if Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h are of the same vendor */
#if (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_VENDOR_ID_H != PORT_CFG_VENDOR_ID_H)
#error "Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h have different vendor ids"
#endif
/* Check if Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h are of the same Autosar version */
#if ((SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MAJOR_VERSION_H !=   \
         PORT_CFG_AR_RELEASE_MAJOR_VERSION_H) ||                     \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_MINOR_VERSION_H !=    \
        PORT_CFG_AR_RELEASE_MINOR_VERSION_H) ||                      \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_AR_RELEASE_REVISION_VERSION_H != \
        PORT_CFG_AR_RELEASE_REVISION_VERSION_H))
#error "AutoSar Version Numbers of Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h are different"
#endif

/* Check if Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h are of the same software version */
#if ((SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MAJOR_VERSION_H != PORT_CFG_SW_MAJOR_VERSION_H) || \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_MINOR_VERSION_H != PORT_CFG_SW_MINOR_VERSION_H) ||  \
    (SIUL2_PORT_IP_TRUSTEDFUNCTIONS_SW_PATCH_VERSION_H != PORT_CFG_SW_PATCH_VERSION_H))
#error "Software Version Numbers of Siul2_Port_Ip_TrustedFunctions.h and Port_Cfg.h are different"
#endif

/*==================================================================================================
*                                      DEFINES AND MACROS
==================================================================================================*/

/*==================================================================================================
                                       GLOBAL VARIABLES
==================================================================================================*/

/*==================================================================================================
*                                     FUNCTION PROTOTYPES
==================================================================================================*/

extern void Port_Init_ClearIMCR_RunTime(const Port_ConfigType* pConfigPtr);

extern void Port_Init_UnusedPins_RunTime(const Port_ConfigType* pConfigPtr);

extern void Siul2_Port_Ip_PinInit(const Siul2_Port_Ip_PinSettingsConfig* config);

#if (STD_ON == PORT_SET_PIN_DIRECTION_API) || (STD_ON == PORT_SET_PIN_MODE_API)
extern Std_ReturnType Port_SetPinDirectionRunTime(Port_PinType PinIndex,
    Port_PinDirectionType eDirection, const Port_ConfigType* pConfigPtr);
#endif /* (STD_ON == PORT_SET_PIN_DIRECTION_API) || (STD_ON == PORT_SET_PIN_MODE_API) */

#ifdef PORT_CODE_SIZE_OPTIMIZATION
#if (STD_ON == PORT_SET_PIN_MODE_API) && (STD_OFF == PORT_CODE_SIZE_OPTIMIZATION)
extern Std_ReturnType Port_SetPinModeRunTime(Port_PinType PinIndex, Port_PinModeType PinMode,
    const Port_ConfigType* pConfigPtr);
#endif /* (STD_ON == PORT_SET_PIN_MODE_API) && (STD_OFF == PORT_CODE_SIZE_OPTIMIZATION) */
#endif /* PORT_CODE_SIZE_OPTIMIZATION */

extern void Port_RefreshPortDirectionRunTime(const Port_ConfigType* pConfigPtr);

#ifdef PORT_SET_AS_UNUSED_PIN_API
#if (STD_ON == PORT_SET_AS_UNUSED_PIN_API)
extern void Port_SetAsUnusedPinRunTime(Port_PinType PinIndex, const Port_ConfigType* pConfigPtr);

extern void Port_SetAsUsedPinRunTime(Port_PinType PinIndex, const Port_ConfigType* pConfigPtr);
#endif /* (STD_ON == PORT_SET_AS_UNUSED_PIN_API) */
#endif /* PORT_SET_AS_UNUSED_PIN_API */

#ifdef PORT_CODE_SIZE_OPTIMIZATION
#ifdef PORT_RESET_PIN_MODE_API
#if (STD_ON == PORT_RESET_PIN_MODE_API) && (STD_OFF == PORT_CODE_SIZE_OPTIMIZATION)
extern void Port_ResetPinModeRunTime(Port_PinType PinIndex, const Port_ConfigType* pConfigPtr);
#endif /* (STD_ON == PORT_RESET_PIN_MODE_API) && (STD_OFF == PORT_CODE_SIZE_OPTIMIZATION) */
#endif /* PORT_RESET_PIN_MODE_API */
#endif /* PORT_CODE_SIZE_OPTIMIZATION */

extern void Siul2_Port_Ip_ConfigInternalResistor(Siul2_Port_Ip_PortType* const base, uint16 pin,
    Siul2_Port_Ip_PortPullConfig pullConfig);

extern void Siul2_Port_Ip_ConfigOutputBuffer(Siul2_Port_Ip_PortType* const base, uint16 pin,
    boolean enable, Siul2_Port_Ip_PortMux mux);

extern void Siul2_Port_Ip_ConfigInputBuffer(Siul2_Port_Ip_PortType* const base, uint16 pin,
    boolean enable, uint32 inputMuxReg, Siul2_Port_Ip_PortInputMux inputMux);

extern void Siul2_Port_Ip_SetPinDirection(Siul2_Port_Ip_PortType* const base, uint16 pin,
    Siul2_Port_Ip_PortDirectionType direction);

extern uint32 Siul2_Port_Ip_GetValueConfigRevertPin(const Siul2_Port_Ip_PortType* const base,
    uint16 pin);

extern void Siul2_Port_Ip_GetValuePinConfiguration(const Siul2_Port_Ip_PortType* const base,
    Siul2_Port_Ip_PinSettingsConfig* config, uint16 pin);

#ifdef __cplusplus
}
#endif

/** @} */

#endif /* SIUL2_PORT_IP_TRUSTEDFUNCTIONS_H */
