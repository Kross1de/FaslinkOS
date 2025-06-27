CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror -fno-stack-protector
LDFLAGS=-T boot/linker.ld -melf_i386
OBJS=boot/boot.o kernel.o vga.o string.o

all:disk.img

disk.img:$(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

kernel.o:kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

vga.o:vga.asm
	$(AS) $< $@

string.o:string.asm
	$(AS) $< $@

clean:
	rm -f $(OBJS) disk.img

run:disk.img
	qemu-system-i386 -drive file=disk.img,format=raw

.PHONY:all clean run
