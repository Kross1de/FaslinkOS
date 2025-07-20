CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror -fno-stack-protector
LDFLAGS=-T linker.ld -melf_i386
OBJS=boot/boot.o kernel.o vga.o string.o stdio.o stdlib.o ctype.o

all:build/disk.img

build/disk.img:$(OBJS)
	mkdir -p build/
	$(LD) $(LDFLAGS) $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

kernel.o:kernel.asm
	$(AS) $< $@

vga.o:vga.asm
	$(AS) $< $@

stdio.o:stdio.asm
	$(AS) $< $@

string.o:string.asm
	$(AS) $< $@

stdlib.o:stdlib.asm
	$(AS) $< $@

ctype.o:ctype.asm
	$(AS) $< $@

clean:
	rm -rf $(OBJS) build/

run:build/disk.img
	qemu-system-i386 -drive file=build/disk.img,format=raw

.PHONY:all clean run
