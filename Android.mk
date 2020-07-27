#
# Copyright (C) 2020 Bithium S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := rtl8188eus

ifeq ($(RTL8188EUS_KERNEL_PATH),)
$(error RTL8188EUS_KERNEL_PATH not defined)
endif

ifeq ($(TARGET_KERNEL_ARCH),)
$(error TARGET_KERNEL_ARCH not defined)
endif

# Check target arch.
TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin)
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin)
else
$(error kernel arch not supported at present)
endif

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/arm-linux-androidkernel-
KERNEL_SRC_ARCH := arm
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
else
$(error kernel arch not supported at present)
endif

# Allow caller to override toolchain.
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(strip $(TARGET_KERNEL_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_KERNEL_CROSS_COMPILE_PREFIX),)
KERNEL_CROSS_COMPILE := $(TARGET_KERNEL_CROSS_COMPILE_PREFIX)
endif

# Set the output for the kernel build products.
MODULE_SRC := $(LOCAL_PATH)
MODULE_OUT = $(realpath $(KERNEL_OUT))

RTL8188EUS_MODULE_CFLAGS += -mno-android
RTL8188EUS_MODULE_CFLAGS += -DCONFIG_PLATFORM_ANDROID
RTL8188EUS_MODULE_CFLAGS += -DCONFIG_LITTLE_ENDIAN
RTL8188EUS_MODULE_CFLAGS += -DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT
RTL8188EUS_MODULE_CFLAGS += -DRTW_P2P_GROUP_INTERFACE=1
RTL8188EUS_MODULE_CFLAGS += -DCONFIG_USE_USB_BUFFER_ALLOC_RX
RTL8188EUS_MODULE_CFLAGS += -DCONFIG_USE_USB_BUFFER_ALLOC_TX

MODULE_ARGS := ARCH=$(KERNEL_SRC_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
	CONFIG_RTL8188E=y CONFIG_USB_HCI=y \
	KSRC=$(realpath $(RTL8188EUS_KERNEL_PATH)) \
	USER_EXTRA_CFLAGS="$(RTL8188EUS_MODULE_CFLAGS)"

$(LOCAL_MODULE): $(KERNEL_BIN)
	$(MAKE) V=1 -C $(MODULE_SRC) O=$(MODULE_OUT) $(MODULE_ARGS)

$(KERNEL_MODULES_INSTALL): $(LOCAL_MODULE)
