# How to build Android Lollipop 5.x for BeagleBone Black

This is a "work in progress", don't expect everything to go smoothly.

This build has been tested on a BBB rev A (2 GiB internal eMMC) with an
LCD4 cape. Here are some issues that I am aware of

1. The boot time is long, expect to wait several minutes
2. The graphics are not accelerated and the screen flickers when updating
3. The buttons on the screen do not work
4. The Ethernet interface is not configured

These instructions use `AOSP 5.1.0_r5` from Google and bootloader, kernel
and graphics drivers from TI Rowboat (http://arowboat.org). They were tested
using Ubuntu 12.04 on the build machine and a BeagelBone Black A6 as the target.

The level is quite advanced: I assume that you are familiar with Linux
command-line tools, including make.


There are two install options

1. Create a bootable micro SD card and boot the BeagleBone from that
2. Install a version of u-boot with fastboot support in the internal eMMC and use the fastboot command to flash the Android image files

Option (1) is probably the easier, so if in doubt I advise you to start there.

Overall, the steps are

1. Get AOSP source from Google
2. Get my device files for the BeagleBone Black
3. Get the Rowboat kernel
4. Get the Rowboat SGX 530 GPU drivers
5. Get the Rowboat U-Boot
6. Build everything
7. Either put it on a micro SD card or flash using fastboot

Make sure that you have a system capable to building AOSP in a reasonable
amount of time as described here
(http://source.android.com/source/building.html).
Then follow these steps to set it up
(http://source.android.com/source/initializing.html)

For reference, I tested on two machines: one a laptop with dual core i7 and
4 GiB RAM running Ubuntu 12.04 64 bit (AOSP build takes more than 3 hours),
and the other an octo core AMD FX-8150 with 16 GiB RAM (takes 1 hour).

You will need in addition the U-Boot mkimage tool. On Ubuntu 12.04 run
`sudo apt-get install u-boot-tools`

# Get AOSP version 5.1.0_r5
Note: in the following I am installing and building everything in directory
`~/aosp`. You may use whichever directory you wish but you will have to modify
the paths used below accordingly.

Begin by getting the repo tool and using it to download the AOSP:

```
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo 
$ chmod a+x ~/bin/repo
$ mkdir ~/aosp
$ cd aosp
$ repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.0_r5
$ repo sync -c
```
This takes several hours because there is > 20 GiB to download. When complete
you will have the AOSP code in `~/aosp`


# Get device files for BeagleBone Black
Get my device files for the BeagleBone Black into device/ti/beagleboneblack
```
$ cd ~/aosp/device
$ mkdir ti
$ cd ti
$ git clone https://github.com/csimmonds/bbb-android-device-files.git beagleboneblack
$ cd beagleboneblack
```

Checkout the current version:
```
$ git checkout lollipop-5.1
```

```
$ cd ~/aosp
$ . build/envsetup.sh
$ lunch
```

Select "beagleboneblack-eng"

#Get and build the kernel
The kernel comes from the Rowboat project. It is version 3.2, without device
tree support, but with a small patch to allow "adb reboot bootloader"
to work.
```
$ cd ~/aosp
$ git clone https://gitorious.org/rowboat/kernel.git
$ cd kernel
$ git checkout rowboat-am335x-kernel-3.2
$ patch -p1 < ../device/ti/beagleboneblack/kernel-patches/0001-Reboot-reason-flags-for-BBB.patch
$ patch -p1 < ../device/ti/beagleboneblack/kernel-patches/0002-Tweak-backlight-PWM-for-LCD4-Beaglebone-cape.patch
$ cp ../device/ti/beagleboneblack/kernel-patches/bbb_android_defconfig .config
$ make ARCH=arm oldconfig
$ make ARCH=arm CROSS_COMPILE=arm-eabi- -j4 uImage
$ croot
```
If **installing to eMMC via fastboot** you need to include the kernel binary in
the build:
```
$ cp kernel/arch/arm/boot/zImage device/ti/beagleboneblack/kernel
```

#Build AOSP for BeagleBone
Now you are ready to run the first AOSP build. Note: the -j option to "make"
determines the number of parallel jobs to run. My rule of thumb is to use the
number of CPU cores plus 2
```
$ croot
$ make -j10
```
This takes an hour or two. When complete you will find the compiled Android
system in `~/aosp/out/target/product/beagleboneblack/`

#Get and build U-Boot
If **installing to eMMC via fastboot** build and install as described in this
tutorial http://2net.co.uk/tutorial/fastboot-beaglebone

Otherwise, if installing to an SD card use the U-Boot from Rowboat.
Get and build it like so:
```
$ cd ~/aosp
$ git clone https://gitorious.org/rowboat/u-boot
$ cd u-boot
$ git checkout am335x-v2013.01.01
$ make CROSS_COMPILE=arm-eabi- distclean
$ make CROSS_COMPILE=arm-eabi- am335x_evm_config
$ make CROSS_COMPILE=arm-eabi- 
```

This will create the first stage boot loader, MLO, and the second stage
bootloader, u-boot.bin.

```
If something goes wrong, go back through the steps and try to identify the problem.

#Install option (1): install to SD card
You need a micro SD card of at least 4 GiB capacity. Insert your SD card into
your SD card reader. It will appear as either `/dev/sd?` Or as `/dev/mmcblk?`
Use fdisk or similar to create partitions like this:
```
Partition    type    bootable?   Size (MiB) ID and file system
1          primary      *               64   c  W95 FAT32 (LBA) 
2          primary                      32  83  Linux 
3          primary                      32  83  Linux
4          extended                   ----  (remainder of device)
5          logical                     270  83  Linux 
6          logical                    3080  83  Linux 
7          logical                     270  83  Linux 
```
I am going to leave the details up to you: that way you can't blame me if it
goes wrong, but as mentioned at the start, please do be aware that accidentally
formatting the wrong device, for example your hard drive, is a distinct
possibility. It has happened to me. So, please, double check everything.

Then format the first partition, the boot partition, giving the correct device
node:
```
$ sudo mkfs -t vfat -n "boot" /dev/mmcblk0
```
Create the ramdisk:
```
$ cd ~/aosp
$ mkimage -A arm -O linux -T ramdisk -d out/target/product/beagleboneblack/ramdisk.img uRamdisk
```
Mount the first partition and copy these files to it
1. `u-boot/MLO`
2. `u-boot/u-boot.img`
3. `uRamdisk`
4. `device/ti/beagleboneblack/uEnv.txt`
5. `kernel/arch/arm/boot/uImage`

The remaining image files are already in ext4 format so they can be copied
directly to partitions 5, 6 and 7. For example if the SD card is `/dev/mmcblk0`
then
```
$ cd ~/aosp/out/target/product/beagleboneblack
$ sudo dd if=system.img of=/dev/mmcblk0p5 bs=4M
$ sudo dd if=userdata.img of=/dev/mmcblk0p6 bs=4M
$ sudo dd if=cache.img of=/dev/mmcblk0p7 bs=4M
```
Now put the SD card in your BeagleBone. Hold down the boot button while
powering on to get it to load U-Boot from the SD card. All being well,
you should see the "Android" boot animation after about 30 seconds and the
launcher screen after 2 or 3 minutes. The second time the boot should be
faster, I find it to be about 60 seconds.

#Install option (2): install to eMMC via fastboot
Assuming you have your BeagleBone Black with u-boot/fastboot installed:

1. Plug in the serial-to-USB cable from the BeagleBone to the PC
2. Start your terminal emulator (e.g if using gtkterm: `gtkterm -p /dev/ttyUSB0 -s 115200`)
3. Apply 5V power to the BeagleBone
4. At the “U-Boot#” prompt, type "fastboot"
5. Plug in the USB cable between the mini USB port on the BeagleBone and the PC

Now you can use fastboot to flash the Android images:
```
$ croot
$ fastboot flash userdata
$ fastboot flash cache
$ fastboot flashall
```
The last command flashes boot.img, recovery.img and sytem.img and then
reboots the device.

Reboot the BeagleBone and you should boot into Android.


