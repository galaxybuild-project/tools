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
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d'.' -f2)

if [ ! -f "Makefile" ]; then
    echo "Makefile not found, please run this script in kernel source directory"
    exit 1
fi

install_kernel_su_next() {
    if [ -d "KernelSU-Next" ]; then
        rm -rf KernelSU-Next
    fi
    local version_flag=$1
    curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash $version_flag
}

patch_susfs() {
    local newer_patch=$1
    echo "Entering KernelSU-Next directory..."
    cd KernelSU-Next || exit 1
    if [ $KERNEL_MAJOR -ge 4 ]; then
        if [ $KERNEL_MAJOR -gt 4 ] || ([ $KERNEL_MAJOR -eq 4 ] && [ $KERNEL_MINOR -ge 9 ]); then
            echo "The kernel does support susfs4ksu!, applying SUSFS patch"
            local patch_url="https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/0001-Implement-SUSFS-v1.5.3-universal.patch"
            if [ "$newer_patch" = "true" ]; then
                patch_url="https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/0001-Implement-SUSFS-v1.5.3-newerfixed.patch"
            fi
            curl -LSs "$patch_url" > susfs.patch
            patch -p1 < susfs.patch
            rm -f susfs.patch
        else
            echo "Kernel version is =< 4.9. SUSFS is not supported. Aborting."
            exit 1
        fi
    else
        echo "Kernel version is too old. SUSFS requires kernel version >= 4.9. Aborting."
        exit 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help        Show this help message and exit"
    echo "  -n, --newerpatch  Use alternative SUSFS patch to fix compile errors (for GKI 2.0+ or some kernel source, not recommend to use this if you don't have any issues)"
    echo "  -s <version>      Specify KernelSU-Next version to install (e.g., 'next', 'v1.0.3')"
}

# Parse command-line arguments
NEWER_PATCH="false"
KERNELSU_VERSION=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--newerpatch)
            NEWER_PATCH="true"
            shift
            ;;
        -s)
            KERNELSU_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

VERSION_FLAG=""
if [ -n "$KERNELSU_VERSION" ]; then
    VERSION_FLAG="-s $KERNELSU_VERSION"
fi

echo "############################################"
echo "KernelSU Next with SuSFS Patches"
echo "Made by @blueskychan-dev, @sidex15, @rifsxd"
echo "Lastest updated: 24 January 2025"
echo "############################################"
echo "Checking if KernelSU-Next is installed..."
if [ -d "KernelSU-Next" ]; then
    echo "KernelSU-Next is installed, uninstalling..."
    rm -rf KernelSU-Next
else
    echo "KernelSU-Next is not installed"
fi
echo "Installing KernelSU-Next..."
install_kernel_su_next "$VERSION_FLAG"
echo "Patching SuSFS..."
patch_susfs "$NEWER_PATCH"
echo "Done! Thanks for using my script :3"
