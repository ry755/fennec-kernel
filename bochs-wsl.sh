#!/usr/bin/env bash
. ./build.sh
echo "starting emulator"
echo "note: bochs has some weird issues with speed, it may be a bit faster or slower than expected"
/mnt/c/Program\ Files/Bochs-2.6.11/bochsdbg.exe 'magic_break: enabled=1' 'cpu: reset_on_triple_fault=0' 'boot:floppy' 'floppya: 1_44=bin/boot.img, status=inserted' 'debug_symbols: file=bin/kernel/kernel.sym, offset=0x4000' 'clock: sync=realtime, rtc_sync=true'
