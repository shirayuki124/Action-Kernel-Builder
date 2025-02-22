#!/bin/bash

#set -e

KERNEL_REPO=/home/runner/work/Action-Kernel-Builder/Action-Kernel-Builder/Kernel
KERNEL_CONFIG=arch/arm64/configs/gki_defconfig
KSU_PATCH_SUSFS=susfs4ksu/kernel_patches

# Clone KernelSU
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main $KERNEL_REPO

# Clone SusFS
git clone -b gki-android13-5.15 https://gitlab.com/simonpunk/susfs4ksu.git $KERNEL_REPO/susfs4ksu

# Copy the patch to KernelSU
cp ./$KSU_PATCH_SUSFS/KernelSU/10_enable_susfs_for_ksu.patch $KERNEL_REPO

# Copy SUSFS kernel patch to GKI kernel
cp ./$KSU_PATCH_SUSFS/50_add_susfs_in_kernel-5.15.patch $KERNEL_REPO

# Copy file system files and header files
cp ./$KSU_PATCH_SUSFS/fs/* $KERNEL_REPO/fs
cp ./$KSU_PATCH_SUSFS/include/linux/* $KERNEL_REPO/include/linux

# Go to the KernelSU directory and apply the patch.
patch -p1 < 10_enable_susfs_for_ksu.patch

# Apply patches to the GKI kernel
patch -p1 < 50_add_susfs_in_kernel-5.15.patch

# Add Config
echo "CONFIG_KSU=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> $KERNEL_CONFIG
echo "CONFIG_KSU_SUSFS_SUS_SU=y" >> $KERNEL_CONFIG

# show config
cat $KERNEL_CONFIG | grep CONFIG_KSU

# Start Build
chmod +x scripts/build.sh
make clean ARCH=arm64 && make mrproper ARCH=arm64 && rm -rf out
./scripts/build.sh
