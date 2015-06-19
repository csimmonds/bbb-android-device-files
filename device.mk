#
# Copyright (C) 2011 The Android Open-Source Project
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

PRODUCT_COPY_FILES := \
	device/ti/beagleboneblack/kernel:kernel \
	device/ti/beagleboneblack/init.am335xevm.rc:root/init.am335xevm.rc \
	device/ti/beagleboneblack/init.am335xevm.usb.rc:root/init.am335xevm.usb.rc \
	device/ti/beagleboneblack/vold.fstab:system/etc/vold.fstab \
	device/ti/beagleboneblack/ueventd.am335xevm.rc:root/ueventd.am335xevm.rc \
	device/ti/beagleboneblack/media_codecs.xml:system/etc/media_codecs.xml \
	device/ti/beagleboneblack/media_profiles.xml:system/etc/media_profiles.xml \
	device/ti/beagleboneblack/mixer_paths.xml:system/etc/mixer_paths.xml \
	device/ti/beagleboneblack/audio_policy.conf:system/etc/audio_policy.conf

ifneq ($(filter beagleboneblack_sd, $(TARGET_PRODUCT)),)
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/fstab.am335xevm-sd:root/fstab.am335xevm
else
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/fstab.am335xevm:root/fstab.am335xevm
endif

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml

# Need AppWidget permission to prevent Launcher[2|3] crashing
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.app_widgets.xml:system/etc/permissions/android.software.app_widgets.xml

# KeyPads
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
    $(LOCAL_PATH)/ti-tsc.idc:system/usr/idc/ti-tsc.idc

# BeagleBone Black only has 512 MiB RAM
PRODUCT_PROPERTY_OVERRIDES := \
      ro.config.low_ram=true

# Explicitly specify dpi, otherwise the icons don't show up correctly with SGX enabled
PRODUCT_PROPERTY_OVERRIDES += \
       ro.sf.lcd_density=160

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.strictmode.visual=0 \
	persist.sys.strictmode.disable=1

PRODUCT_CHARACTERISTICS := tablet,nosdcard

DEVICE_PACKAGE_OVERLAYS := \
   device/ti/beagleboneblack/overlay

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
	librs_jni \
	com.android.future.usb.accessory

PRODUCT_PACKAGES += \
	libaudioutils

PRODUCT_PACKAGES += \
        audio.primary.beagleboneblack \
        tinycap \
        tinymix \
        tinyplay

PRODUCT_PACKAGES += \
	dhcpcd.conf

# Filesystem management tools
PRODUCT_PACKAGES += \
	make_ext4fs

# Backlight HAL (liblights)
PRODUCT_PACKAGES += \
	lights.beagleboneblack

PRODUCT_PACKAGES += \
	androidvncserver

PRODUCT_PACKAGES += \
	camera.omap3

# Use pixel flinger (libGLES_android.so) as a backup to SGX
PRODUCT_PACKAGES += \
	libGLES_android

# Include SGX if they exist: they won't on the first build
ifneq ($(wildcard device/ti/beagleboneblack/sgx/system),)
    $(call inherit-product, device/ti/beagleboneblack/device-sgx.mk)
endif

# Configure the Dalvik heap for a device with 512 MiB RAM
$(call inherit-product, frameworks/native/build/phone-hdpi-512-dalvik-heap.mk)
