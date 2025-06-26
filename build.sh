#!/bin/sh

set -ex
CFLAGS="-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror"
OBJS="boot/boot.o vga.o"
fasm boot/boot.asm
fasm vga.asm
gcc ${CFLAGS} boot/kernel.c -T boot/linker.ld ${OBJS} -fno-pic -o disk.img
rm ${OBJS}