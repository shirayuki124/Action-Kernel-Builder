#!/bin/bash

#set -e

KERNEL_REPO=Kernel
KERNEL_CONFIG=arch/arm64/configs/gki_defconfig

# Clone KernelSU
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main $KERNEL_REPO/KernelSU

# Clone SusFS
git clone -b gki-android13-5.15 https://gitlab.com/simonpunk/susfs4ksu.git

# Copy the patch to KernelSU
cp ./kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch $KERNEL_REPO/KernelSU

# Copy SUSFS kernel patch to GKI kernel
cp ./kernel_patches/50_add_susfs_in_kernel-5.15.patch $KERNEL_REPO

# Copy file system files and header files
cp ./kernel_patches/fs/* $KERNEL_REPO/fs
cp ./kernel_patches/include/linux/* $KERNEL_REPO/include/linux/

# Go to the KernelSU directory and apply the patch.
cd $KERNEL_REPO/KernelSU
patch -p1 < 10_enable_susfs_for_ksu.patch

# Apply patches to the GKI kernel
cd $KERNEL_REPO
patch -p1 < 50_add_susfs_in_kernel-5.15.patch

# Add Config
cd $KERNEL_REPO
echo "CONFIG_KSU=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS_SUS_SU=y" >> $KERNEL_CONFIG

# Start Build
./scripts/build.sh