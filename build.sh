#!/usr/bin/env bash
set -e
mkdir -p bin/{bootloader,kernel}

CC=~/opt/cross/bin/i686-elf-gcc

echo "assembling stage1"
nasm bootloader/stage1.s -f bin -o bin/bootloader/stage1.bin
echo "assembling stage2"
nasm bootloader/stage2.s -f bin -o bin/bootloader/stage2.bin
echo "assembling kernel"
nasm kernel/kernel.s -i "kernel/include" -g -F dwarf -f elf32 -o bin/kernel/kernel.o
echo "compiling kernel extensions"
for ext in putchar puts puthex hlmm dmem rand view_render; do
  $CC -Wall -Wextra -std=c17 -m32 -march=i386 -masm=intel -mstackrealign -fno-pie -ffreestanding -nostdlib -O2 -c -o bin/kernel/$ext.o -x c kernel/include/c/$ext.c
done
echo "creating kernel flat binary"
ld -m elf_i386 -Ttext=0x4000 -e real_start --oformat binary -o bin/kernel/kernel.bin bin/kernel/kernel.o bin/kernel/putchar.o bin/kernel/puts.o bin/kernel/puthex.o bin/kernel/hlmm.o bin/kernel/dmem.o bin/kernel/rand.o bin/kernel/view_render.o

echo "creating kernel symbol file (.text only)"
nm bin/kernel/kernel.o -p | grep ' T \| t ' | awk '{ print $1" "$3 }' > bin/kernel/kernel.sym

echo "creating kernel symbol file (all sections, line numbers included)"
nm bin/kernel/kernel.o -l -p > bin/kernel/kernel_debug.sym

echo "creating boot image"
python3 ryfs/ryfs.py create bin/boot.img -l fennec -s 1474560 -b bin/bootloader/stage1.bin
python3 ryfs/ryfs.py add bin/boot.img bin/bootloader/stage2.bin
python3 ryfs/ryfs.py add bin/boot.img bin/kernel/kernel.bin
echo "boot image created"
