#
# Copyright (C) 2011 The Android Open-Source Project
# Copyright (C) 2015 Chris Simmonds, chris@2net.co.uk
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

# PowerVR SGX graphics

# These are the kernel modules and a script to load and unload them
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/sgx/system/bin/sgx/omaplfb.ko:system/bin/sgx/omaplfb.ko \
	device/ti/beagleboneblack/sgx/system/bin/sgx/pvrsrvkm.ko:system/bin/sgx/pvrsrvkm.ko \
	device/ti/beagleboneblack/sgx/system/bin/sgx/rc.pvr:system/bin/sgx/rc.pvr

# These are the GLES and EGL libraries
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/sgx/system/lib/egl/libEGL_POWERVR_SGX530_125.so:system/lib/egl/libEGL_POWERVR_SGX530_125.so \
	device/ti/beagleboneblack/sgx/system/lib/egl/libGLESv1_CM_POWERVR_SGX530_125.so:system/lib/egl/libGLESv1_CM_POWERVR_SGX530_125.so \
	device/ti/beagleboneblack/sgx/system/lib/egl/libGLESv2_POWERVR_SGX530_125.so:system/lib/egl/libGLESv2_POWERVR_SGX530_125.so

# This is the gralloc implementation
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/sgx/system/lib/hw/gralloc.omap3.so:system/lib/hw/gralloc.omap3.so

# These are utility programs called by the module load script
PRODUCT_COPY_FILES += \
        device/ti/beagleboneblack/sgx/system/bin/pvrsrvctl:system/bin/pvrsrvctl \
        device/ti/beagleboneblack/sgx/system/bin/pvrsrvinit:system/bin/pvrsrvinit

# These are various libraries used by the components above
PRODUCT_COPY_FILES += \
	device/ti/beagleboneblack/sgx/system/lib/libglslcompiler.so:system/lib/libglslcompiler.so \
	device/ti/beagleboneblack/sgx/system/lib/libIMGegl.so:system/lib/libIMGegl.so \
	device/ti/beagleboneblack/sgx/system/lib/libpvr2d.so:system/lib/libpvr2d.so \
	device/ti/beagleboneblack/sgx/system/lib/libpvrANDROID_WSEGL.so:system/lib/libpvrANDROID_WSEGL.so \
	device/ti/beagleboneblack/sgx/system/lib/libPVRScopeServices.so:system/lib/libPVRScopeServices.so \
	device/ti/beagleboneblack/sgx/system/lib/libsrv_init.so:system/lib/libsrv_init.so \
	device/ti/beagleboneblack/sgx/system/lib/libsrv_um.so:system/lib/libsrv_um.so \
	device/ti/beagleboneblack/sgx/system/lib/libusc.so:system/lib/libusc.so

