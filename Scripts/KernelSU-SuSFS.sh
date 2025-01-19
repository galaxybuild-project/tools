#!/bin/bash

#set -e

#
# Copyright (C) 2025 blueskychan-dev
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

KERNEL_VERSION=$(make kernelversion | grep -v "Entering\|Leaving")
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d'.' -f1)

if [ ! -f "Makefile" ]; then
    echo "Makefile not found, please run this script in kernel source directory"
    exit 1
fi

install_kernel_su_next() {
    if [ -d "KernelSU-Next" ]; then
        rm -rf KernelSU-Next
    fi
    curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -
}

patch_susfs() {
    echo "Entering to KernelSU-Next directory..."
    cd KernelSU-Next
    if [ $KERNEL_MAJOR -ge 5 ]; then
        if [ $KERNEL_MAJOR -ge 10 ]; then
        echo "Kernel version is >=5.10, using GKI patch"
        curl -LSs "https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/0001-KernelSU-Next-Implement-SUSFS-v1.5.3-plus-GKI.patch" > susfs.patch
        else
            echo "Kernel version is <=5.10, using non-GKI patch"
            curl -LSs "https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/0001-KernelSU-Next-Implement-susfs-v1.5.3-plus-non-gki.patch" > susfs.patch
        fi
        patch -p1 < susfs.patch
        rm -f susfs.patch
    else
            echo "Kernel version is <=5.10, using non-GKI patch"
            curl -LSs "https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/0001-KernelSU-Next-Implement-susfs-v1.5.3-plus-non-gki.patch" > susfs.patch
        echo "Kernel version is too old, please use kernel version >=4.0"
        patch -p1 < susfs.patch
        rm -f susfs.patch
    fi
}

echo "############################################"
echo "KernelSU Next with SuSFS Patches"
echo "Made by @blueskychan-dev, @sidex15, @rifsxd"
echo "############################################"
echo "Checking if KernelSU-Next is installed..."
if [ -d "KernelSU-Next" ]; then
    echo "KernelSU-Next is installed, uninstalling..."
    rm -rf KernelSU-Next
else
    echo "KernelSU-Next is not installed"
fi
echo "Installing KernelSU-Next..."
install_kernel_su_next
echo "Patching SuSFS..."
patch_susfs
echo "Done!, Thanks for using my script :3"
