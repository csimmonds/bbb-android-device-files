# For PowerVR SGX graphics
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


$(call inherit-product, frameworks/native/build/tablet-dalvik-heap.mk)
