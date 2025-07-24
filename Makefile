CC=gcc
AS=fasm
LD=ld
CFLAGS=-m32 -nostdlib -ffreestanding -fno-pic -Wall -Wextra -Werror -fno-stack-protector
LDFLAGS=-T linker.ld -melf_i386
SOURCEDIRS=boot/ kernel/ drivers/ library/

# sources/objects
ASMS=$(shell find $(SOURCEDIRS) -type f -name '*.asm')
GCCS=$(shell find $(SOURCEDIRS) -type f -name '*.c')
ASMO=$(ASMS:.asm=.o)
GCCO=$(GCCS:.c=.o)
OBJS=$(ASMO) $(GCCO)

all:build/disk.img

build/disk.img:$(OBJS)
	mkdir -p build/
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.asm
	$(AS) $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJS) build/

run:build/disk.img
	qemu-system-i386 -drive file=build/disk.img,format=raw

.PHONY:all clean run
