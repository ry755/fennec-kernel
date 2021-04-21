#!/usr/bin/env bash
set -e
mkdir -p bin/{bootloader,kernel}

echo "assembling stage1"
nasm bootloader/stage1.s -f bin -o bin/bootloader/stage1.bin
echo "assembling stage2"
nasm bootloader/stage2.s -f bin -o bin/bootloader/stage2.bin
echo "assembling kernel"
nasm kernel/kernel.s -i "kernel/include" -g -F dwarf -f elf32 -o bin/kernel/kernel.o
echo "creating kernel flat binary"
ld -m elf_i386 -Ttext=0x4000 -e real_start --oformat binary -o bin/kernel/kernel.bin bin/kernel/kernel.o

echo "creating kernel symbol file (.text only)"
nm bin/kernel/kernel.o -p | grep ' T \| t ' | awk '{ print $1" "$3 }' > bin/kernel/kernel.sym

echo "creating kernel symbol file (all sections, line numbers included)"
nm bin/kernel/kernel.o -l -p > bin/kernel/kernel_debug.sym

echo "creating boot image"
./ryfs/ryfs.py create bin/boot.img -l Fennec -s 1474560 -b bin/bootloader/stage1.bin
./ryfs/ryfs.py add bin/boot.img bin/bootloader/stage2.bin
./ryfs/ryfs.py add bin/boot.img bin/kernel/kernel.bin
echo "boot image created"
