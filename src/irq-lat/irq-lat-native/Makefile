# Prepare enviroment for baremetal-runtime
NAME:=irq-lat-native
ROOT_DIR:=$(realpath .)
BUILD_DIR:=$(ROOT_DIR)/build/$(NAME)

# Setup baremetal-runtime build
include $(bmrt_dir)/setup.mk


# Inlcude all sources

# Main freertos application sources
APP_SRC_DIR?=$(ROOT_DIR)
include $(APP_SRC_DIR)/sources.mk
C_SRC+=$(addprefix $(APP_SRC_DIR)/, $(src_c_srcs))

INIT_SRC_DIR?=$(BENCHMARKS_ROOT)/configs/$(PLATFORM)/benchmark/init
include $(INIT_SRC_DIR)/sources.mk
C_SRC+=$(addprefix $(INIT_SRC_DIR)/, $(init_src_c_srcs))
INIT_INC_DIR := $(shell find "$(INIT_SRC_DIR)" -type d -print)
INC_DIRS += $(INIT_INC_DIR)

# Include the final baremetal-runtime build
include $(bmrt_dir)/build.mk

