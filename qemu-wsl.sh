#!/usr/bin/env bash
. ./build.sh
echo "starting emulator"
/mnt/c/Program\ Files/qemu/qemu-system-i386.exe -drive file=bin/boot.img,format=raw,index=0,media=disk,if=floppy
