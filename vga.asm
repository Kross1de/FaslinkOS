format elf
section '.text' executable
;; 32 bit protected mode
use32
public vga_init
public vga_putc
public vga_print

VGA_BUFFER = 0xb8000
VGA_WIDTH = 80
VGA_HEIGHT = 25

VGA_COLOUR_BLACK         = 0
VGA_COLOUR_BLUE          = 1
VGA_COLOUR_GREEN         = 2
VGA_COLOUR_CYAN          = 3
VGA_COLOUR_RED           = 4
VGA_COLOUR_MAGENTA       = 5
VGA_COLOUR_BROWN         = 6
VGA_COLOUR_LIGHT_GREY    = 7
VGA_COLOUR_DARK_GREY     = 8
VGA_COLOUR_LIGHT_BLUE    = 9
VGA_COLOUR_LIGHT_GREEN   = 10
VGA_COLOUR_LIGHT_CYAN    = 11
VGA_COLOUR_LIGHT_RED     = 12
VGA_COLOUR_LIGHT_MAGENTA = 13
VGA_COLOUR_LIGHT_BROWN   = 14
VGA_COLOUR_WHITE         = 15


ASCII_NEWLINE         = 0x0a
ASCII_CARRIAGE_RETURN = 0x0d

vga_init:
    mov word [vga_x], 0
    mov word [vga_y], 0
    mov word [vga_colour], VGA_COLOUR_WHITE
    ret

vga_putc:
    push ebp
    mov ebp, esp
    ; Ignore EAX, ECX and EDX
    mov eax, [ebp + 8]
    cmp eax, ASCII_NEWLINE
    je .newline
    cmp eax, ASCII_CARRIAGE_RETURN
    je .carriage
    pushd [vga_y]
    pushd [vga_x]
    pushd [vga_colour]
    pushd [ebp + 8]
    call vga_putc_at
    mov eax, [vga_x]
    inc eax
    cmp eax, VGA_WIDTH
    je .newline
    mov [vga_x], eax
    jmp .return
.newline:
    mov eax, [vga_y]
    inc eax
    mov [vga_y], eax
.carriage:
    mov dword [vga_x], 0
.return:
    mov esp, ebp
    pop ebp
    ret

vga_print:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    mov esi, [ebp + 8]
.loop:
    lodsb
    or al,al
    jz .return
    push eax
    call vga_putc
    jmp .loop
.return:
    pop ebx
    pop esi
    mov esp, ebp
    pop ebp
    ret

vga_putc_at:
    push ebp
    mov ebp, esp
    or eax, eax
    mov al, [ebp + (4 * 5)]
    mov ecx, VGA_WIDTH
    mul ecx
    add al, [ebp + (4 * 4)]
    shl eax, 1
    add eax, VGA_BUFFER
    mov cl, [ebp + (4 * 2)]
    mov ch, [ebp + (4 * 3)]
    mov word [eax], cx
.return:
    mov esp, ebp
    pop ebp
    ret

section '.bss'
vga_x:      dd 0
vga_y:      dd 0
vga_colour: dd 0
