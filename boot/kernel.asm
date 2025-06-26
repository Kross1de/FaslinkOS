format elf
section '.text' executable
public kmain
extrn vga_putchar
extrn vga_puts

use32

kmain:
    push ebp
    mov ebp, esp

    push eax
    push ecx
    push edx
    push hello_str
    call vga_puts
    pop edx
    pop ecx
    pop eax
.return:
    mov esp, ebp
    pop ebp
    ret

hello_str: db "Hello from kernel.asm", 0x0a, 0
