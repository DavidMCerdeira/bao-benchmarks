# Prepare enviroment for baremetal-runtime
NAME:=ctx-switch-guest2
ROOT_DIR:=$(realpath .)
BUILD_DIR:=$(ROOT_DIR)/build/$(NAME)

# Setup baremetal-runtime build
include $(bmrt_dir)/setup.mk


# Inlcude all sources

# Main freertos application sources
APP_SRC_DIR?=$(ROOT_DIR)
include $(APP_SRC_DIR)/sources.mk
C_SRC+=$(addprefix $(APP_SRC_DIR)/, $(src_c_srcs))

bench_helper_src_dir?=$(bench_helper_dir)/$(PLATFORM)
include $(bench_helper_src_dir)/sources.mk
C_SRC+=$(addprefix $(bench_helper_dir)/, $(bench_helpers_src_c_srcs))
ASM_SRC+=$(addprefix $(bench_helper_dir)/, $(bench_helpers_src_s_srcs))
HELPERS_INC_DIR := $(shell find "$(bench_helper_src_dir)" -type d -print)
INC_DIRS += $(HELPERS_INC_DIR)

# Include the final baremetal-runtime build
include $(bmrt_dir)/build.mk

