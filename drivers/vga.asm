format elf
section '.text' executable
use32
public vga_init
public vga_putchar
public vga_puts
public vga_putnl

include 'include/string.inc'
include 'include/kernel.inc'

extrn busy_loop

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
ASCII_TAB             = 0x09

NUM_SPACES_PER_TAB = 4

vga_init:
    mov word [vga_x], 0
    mov word [vga_y], 0
    mov word [vga_fg_colour], VGA_COLOUR_LIGHT_BROWN
    mov word [vga_bg_colour], VGA_COLOUR_MAGENTA
    ret

vga_putnl:
    enter 0, 0
    push ASCII_NEWLINE
    call vga_putchar
    add esp, WORD_SIZE
    leave
    ret

vga_putchar:
    enter 0, 0
    push ebx
    mov eax, [ebp + 8]
    cmp eax, ASCII_NEWLINE
    je .newline
    cmp eax, ASCII_CARRIAGE_RETURN
    je .carriage
    cmp eax, ASCII_TAB
    je .tab
    pushd [vga_y]
    pushd [vga_x]
    pushd [vga_bg_colour]
    pushd [vga_fg_colour]
    pushd [ebp + 8]
    call vga_putchar_at
    add esp, 5*WORD_SIZE
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
    cmp eax, VGA_HEIGHT
    jne .carriage
    call vga_scroll
    ; fall through to carriage (so \n is equiv to \r\n (or even \n\r))
.carriage:
    mov dword [vga_x], 0
    jmp .return
.tab:
    mov ebx, NUM_SPACES_PER_TAB
.loop:
    pushd " "
    call vga_putchar
    add esp, WORD_SIZE
    dec ebx
    test ebx, ebx
    je .return
    jmp .loop
.return:
    ; Return the character printed
    mov eax, [ebp + 8]
    pop ebx
    leave
    ret

vga_puts:
    enter 0, 0
    push esi
    xor eax, eax
    mov esi, [ebp + 8]
    ; TODO check for NULL
.loop:
    lodsb
    or al,al
    jz .return
    push eax
    call vga_putchar
    add esp, WORD_SIZE
    jmp .loop
.return:
    ; TODO error cases
    mov eax, 0
    pop esi
    leave
    ret

vga_putchar_at:
    enter 0, 0
    xor eax, eax
    mov al, [ebp + (4 * 6)]
    mov ecx, VGA_WIDTH
    mul ecx
    xor ecx, ecx
    mov cl, [ebp + (4 * 5)]
    add eax, ecx
    shl eax, 1
    add eax, VGA_BUFFER
    mov edx, eax
    mov cl, [ebp + (4 * 2)]
    mov ch, [ebp + (4 * 3)]
    mov al, [ebp + (4 * 4)]
    shl al, 4
    or al, ch
    mov ch, al
    mov word [edx], cx
.return:
    call busy_loop
    leave
    ret

vga_scroll:
    enter 0, 0
    push ebx

    mov ebx, VGA_WIDTH
    shl ebx, 1
    xor ecx, ecx
.loop:
    push ebx
    inc ecx
    mov eax, ecx
    mul ebx
    add eax, VGA_BUFFER
    push eax
    sub eax, ebx
    push eax
    call memcpy
    add esp, 3*WORD_SIZE
    cmp ecx, VGA_HEIGHT
    jge .return
    jmp .loop
.return:
    mov dword [vga_y], VGA_HEIGHT - 1
    leave
    ret

section '.bss'
vga_x:         dd 0
vga_y:         dd 0
vga_fg_colour: dw 0
vga_bg_colour: dw 0
