#!/usr/bin/env bash
. ./build.sh
echo "starting emulator"
qemu-system-i386 -drive file=bin/boot.img,format=raw,index=0,media=disk,if=floppy
