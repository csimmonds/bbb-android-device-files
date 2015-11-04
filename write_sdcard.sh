#!/bin/bash

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

copy_or_fail()
{
    echo "Copying $1 to $2"
    if ! sudo cp $1 $2; then
        echo "Failed"
        exit 1             
    fi
    sync
}

KERNEL_BINARY=kernel/arch/arm/boot/uImage
if [ ! -f $KERNEL_BINARY ]; then
	KERNEL_BINARY=device/ti/beagleboneblack/kernel-patches/uImage
fi

FILES_NEEDED="u-boot/MLO u-boot/u-boot.img device/ti/beagleboneblack/uEnv.txt $KERNEL_BINARY out/target/product/beagleboneblack/ramdisk.img out/target/product/beagleboneblack/system.img out/target/product/beagleboneblack/userdata.img out/target/product/beagleboneblack/cache.img"

echo "Create a bootable uSD card for BBB"
echo "Requires a uSD card of 2GB or more to be present in the"
echo "SD card reader. THIS CARD WILL BE REFORMATTED"
echo ""

for f in $FILES_NEEDED; do
	if ! [ -e $f ]; then
		echo "ERROR: $f missing"
		exit
	fi
done

# Select device to flash
echo "Available devices:"
lsblk -d
echo "Select device to flash (e.g. sdb, mmcblk0, ...):"
read device
if [ -z $device ]; then
	echo "No device entered!"
	exit
fi

# Unfortunately, some SD card readers do not set the removeable attribute
# so this is not a reliable test
#if [ `cat /sys/block/${device}/removable` = 0 ]; then
#	echo "$device does not look like a removeable SD card!"
#	exit
#fi

# Check it is a reasonable size for a SD card ( < 16 MB)
NUM_SECTORS=`cat /sys/block/${device}/size`
if [ $NUM_SECTORS -eq 0 -o $NUM_SECTORS -gt 32000000 ]; then
	echo "Drive ${device} has ${NUM_SECTORS}, which seems too large to be a"
	echo "uSD card. If it really is one, edit this file and change the"
	echo "limit, but for now I am bailing out"
	exit 1
fi

echo ""

if [ $device == "mmcblk0" ]; then
    BOOT_PART=/dev/${device}p1
    SYSTEM_PART=/dev/${device}p2
    USER_PART=/dev/${device}p3
    CACHE_PART=/dev/${device}p4
else
    BOOT_PART=/dev/${device}1
    SYSTEM_PART=/dev/${device}2
    USER_PART=/dev/${device}3
    CACHE_PART=/dev/${device}4
fi

echo "Unmounting partitions on /dev/${device}"
for f in /dev/${device}*; do
	sudo umount $f
done

echo "Partitioning $device"
sudo dd if=/dev/zero of=/dev/$device bs=512 count=1
sync
sleep 4
sudo sfdisk /dev/${device} << EOF
start=1,size=32M,type=a,bootable,name=boot
size=512M,type=83,name=system
size=512M,type=83,name=userdata
size=256M,type=83,name=cache
EOF
if [ $? != 0 ]; then echo "ERROR"; exit; fi

# Wait while the new partitions are auto mounted
sleep 4

echo "Formatting $BOOT_PART"
# sudo mkfs.vfat -F 32 -s 2 -n boot $BOOT_PART
sudo mkfs.vfat -F 32 -n boot $BOOT_PART
if [ $? != 0 ]; then echo "ERROR"; exit; fi

echo "Mounting $BOOT_PART"
sudo mount $BOOT_PART /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi

copy_or_fail u-boot/MLO /mnt/MLO
copy_or_fail u-boot/u-boot.img /mnt/u-boot.img
copy_or_fail device/ti/beagleboneblack/uEnv.txt /mnt/uEnv.txt

copy_or_fail $KERNEL_BINARY /mnt/uImage

mkimage -A arm -O linux -T ramdisk -d out/target/product/beagleboneblack/ramdisk.img uRamdisk
copy_or_fail uRamdisk /mnt/uRamdisk

echo "Copying system image"
sudo dd if=out/target/product/beagleboneblack/system.img of=$SYSTEM_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $SYSTEM_PART system
echo "Copying userdata image"
sudo dd if=out/target/product/beagleboneblack/userdata.img of=$USER_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $USER_PART userdata
echo "Copying cache image"
sudo dd if=out/target/product/beagleboneblack/cache.img of=$CACHE_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $CACHE_PART cache

sudo umount $BOOT_PART

echo "SUCCESS! SD card created"
