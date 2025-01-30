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
            local patch_url="https://raw.githubusercontent.com/galaxybuild-project/tools/refs/heads/main/Patches/Implement-SUSFS-v1.5.4-for-KernelSU-Next.patch"
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
    echo "  help                Show this help message and exit"
    echo "  <commit-or-tag>:    Sets up or updates the KernelSU-Next to specified tag or commit."
}

# Parse command-line arguments
NEWER_PATCH="false"
KERNELSU_VERSION=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        newerpatch)
            NEWER_PATCH="false"
            shift
            ;;
        help)
            show_help
            exit 0
            ;;
        *)
            KERNELSU_VERSION="$1"
            shift
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
echo "Last updated: 27 January 2025"
echo "############################################"
echo ""
echo "⚠️ This script will be **DEPRECATED** soon!"
echo "Please check the official SuSFS branch:"
echo "➡️ https://rifsxd.github.io/KernelSU-Next/pages/installation.html"
echo ""
echo "For more info, visit:"
echo "➡️ https://t.me/galaxybuild_project/268"
echo ""
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
echo ""
echo "✅ Done! Thanks for using my script :3"

