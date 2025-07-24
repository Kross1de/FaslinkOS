CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror -fno-stack-protector
LDFLAGS=-T linker.ld -melf_i386
OBJS=boot/boot.o kernel/kernel.o drivers/vga.o library/string.o library/stdio.o library/stdlib.o library/ctype.o

all:build/disk.img

build/disk.img:$(OBJS)
	mkdir -p build/
	$(LD) $(LDFLAGS) $(OBJS) -o $@

boot/boot.o:boot/boot.asm
	$(AS) $< $@

kernel/kernel.o:kernel/kernel.asm
	$(AS) $< $@

drivers/vga.o:drivers/vga.asm
	$(AS) $< $@

library/stdio.o:library/stdio.asm
	$(AS) $< $@

library/string.o:library/string.asm
	$(AS) $< $@

library/stdlib.o:library/stdlib.asm
	$(AS) $< $@

library/ctype.o:library/ctype.asm
	$(AS) $< $@

clean:
	rm -rf $(OBJS) build/

run:build/disk.img
	qemu-system-i386 -drive file=build/disk.img,format=raw

.PHONY:all clean run
