format elf
section '.text' executable
public kmain
extrn busy_loop

include 'include/vga.inc'
include 'include/string.inc'

extrn cFn

use32

kmain:
    push ebp
    mov ebp, esp

    push hello_str
    call vga_puts
    call cFn
    pushd 16
    pushd itoa_buf
    pushd 0xC8F3FACE
    call itoa
    test eax, eax
    je .itoa_error
    push eax
    call vga_puts
    call vga_putnl
    jmp .return
.itoa_error:
    push itoa_err_str
    call vga_puts
.return:
    mov esp, ebp
    pop ebp
    ret

hello_str: db "Hello from kernel.asm", 0x0a, 0
itoa_err_str: db "call itoa failed", 0x0a, 0
itoa_buf: times 33 db 0
