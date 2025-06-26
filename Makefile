CC=gcc
AS=fasm
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror
LDFLAGS=-T boot/linker.ld -fno-pic
OBJS=boot/boot.o vga.o

all:disk.img

disk.img:$(OBJS) boot/kernel.c
	$(CC) $(CFLAGS) $(LDFLAGS) boot/kernel.c $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

vga.o:vga.asm
	$(AS) $< $@

clean:
	rm -f $(OBJS) disk.img

run:disk.img
	qemu-system-i386 -drive file=disk.img,format=raw

.PHONY:all clean run
