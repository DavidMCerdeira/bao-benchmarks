# Prepare enviroment for baremetal-runtime
NAME:=ctx-switch-guest1
ROOT_DIR:=$(realpath .)
BUILD_DIR:=$(ROOT_DIR)/build/$(NAME)

# Setup baremetal-runtime build
include $(bmrt_dir)/setup.mk


# Inlcude all sources

# Main freertos application sources
APP_SRC_DIR?=$(ROOT_DIR)
include $(APP_SRC_DIR)/sources.mk
C_SRC+=$(addprefix $(APP_SRC_DIR)/, $(src_c_srcs))

# Include the final baremetal-runtime build
include $(bmrt_dir)/build.mk

