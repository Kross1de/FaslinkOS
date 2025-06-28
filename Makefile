CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror -fno-stack-protector
LDFLAGS=-T linker.ld -melf_i386
OBJS=boot/boot.o kernel.o vga.o string.o test.o tests/test_itoa.o

all:build/disk.img

build/disk.img:$(OBJS)
	mkdir -p build/
	$(LD) $(LDFLAGS) $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

kernel.o:kernel.asm
	$(AS) $< $@

test.o:test.c
	$(CC) $(CFLAGS) -c $< -o $@

tests/test_itoa.o:tests/test_itoa.c
	$(CC) $(CFLAGS) -c $< -o $@

vga.o:vga.asm
	$(AS) $< $@

string.o:string.asm
	$(AS) $< $@

clean:
	rm -rf $(OBJS) build/

run:build/disk.img
	qemu-system-i386 -drive file=build/disk.img,format=raw

.PHONY:all clean run
