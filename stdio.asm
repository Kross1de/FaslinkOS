format elf
section '.text' executable
;; 32 bit protected mode
use32
public puts
public putchar
public putnl
public printf

include 'include/kernel.inc'
include 'include/vga.inc'

puts:
    jmp vga_puts

putchar:
    jmp vga_putchar

putnl:
    jmp vga_putnl

printf:
    enter 0, 0
.return:
    mov eax, -1
    leave
    ret
