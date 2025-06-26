#!/bin/sh

set -ex
CFLAGS="-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror"
OBJS="boot/boot.o boot/boot32.o boot/stack.o"
fasm boot/boot.asm
fasm boot/boot32.asm
fasm boot/stack.asm
gcc ${CFLAGS} boot/kernel.c -T boot/linker.ld ${OBJS} -fno-pic -o disk.img
