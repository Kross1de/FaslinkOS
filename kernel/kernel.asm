format elf
section '.text' executable
public kmain
extrn busy_loop

include 'include/stdio.inc'
include 'include/string.inc'
include 'include/kernel.inc'

use32

kmain:
    enter 0, 0
    push hello_str
    call puts
    add esp, WORD_SIZE
.loop:
    jmp .loop
.return:
	leave
	ret

hello_str:  db "Hello from faslinkOS!", 0
