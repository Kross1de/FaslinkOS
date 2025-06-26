format elf
section '.text' executable
;; 32 bit protected mode
use32
public vga_print

VGA_BUFFER = 0xb8000
vga_print:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    mov esi, [ebp + 8]

    mov ebx, VGA_BUFFER
.loop:
    lodsb
    or al,al
    jz .return
    or eax,0x0100
    mov word [ebx], ax
    add ebx,2
    jmp .loop
.return:
    pop ebx
    pop esi
    mov esp, ebp
    pop ebp
    ret
