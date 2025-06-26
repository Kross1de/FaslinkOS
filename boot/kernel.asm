format elf
section '.text' executable
public kmain
extrn vga_print

use32

kmain:
    push ebp
    mov ebp, esp

    push hello_str
    call vga_print
.return:
    mov esp, ebp
    pop ebp
    ret

hello_str: db "Hello from kernel.asm", 10, 0
