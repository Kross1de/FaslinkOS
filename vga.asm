format elf
section '.text' executable
;; 32 bit protected mode
use32
public vga_print

VGA_BUFFER = 0xb8000
vga_print:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]

    mov ebx, VGA_BUFFER
.loop:
    lodsb
    or al,al
    jz .end
    or eax,0x0100
    mov word [ebx], ax
    add ebx,2
    jmp .loop
.end:
    pop ebp
    ret