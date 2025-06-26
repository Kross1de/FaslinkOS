#!/bin/sh

set -ex
CFLAGS="-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror"
fasm boot.asm
gcc ${CFLAGS} kernel.c -T linker.ld boot.o -o disk.img
