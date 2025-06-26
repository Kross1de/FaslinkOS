format elf
section '.text' executable
public kmain
extrn vga_print

use32

kmain:
    push ebp
    mov ebp, esp

    push eax
    push ecx
    push edx
    push hello_str
    call vga_print
    pop edx
    pop ecx
    pop eax
.return:
    mov esp, ebp
    pop ebp
    ret

hello_str: db "Hello from kernel.asm", 0x0a, 0
