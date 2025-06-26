CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror
LDFLAGS=-T boot/linker.ld -melf_i386
OBJS=boot/boot.o boot/kernel.o vga.o

all:disk.img

disk.img:$(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

boot/kernel.o:boot/kernel.asm
	$(AS) $< $@

vga.o:vga.asm
	$(AS) $< $@

clean:
	rm -f $(OBJS) disk.img

run:disk.img
	qemu-system-i386 -drive file=disk.img,format=raw

.PHONY:all clean run
