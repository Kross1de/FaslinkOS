format elf
section '.text' executable
use32
public keyboard_get_scancode
include 'include/stdio.inc'
include 'include/kernel.inc'

PS2_KEYBOARD_PORT = 0x60

keyboard_get_scancode:
    enter 0, 0
    xor eax, eax
    xor edx, edx
    in al, PS2_KEYBOARD_PORT
    test al, 0x80
    jz .pressed
    jmp .return
.pressed:
    int 3
    mov ecx, scancodes1
    add ecx, eax
    cmp ecx, scancodes1
    jl .non_ascii
    cmp ecx, scancodes1end
    jge .non_ascii
    mov dl, [ecx]
    test dl,dl
    jz .non_ascii
    cmp edx, ASCII_ESCAPE
    jz .escape
    cmp edx, ASCII_BACKSPACE
    jz .backspace
    cmp edx, ASCII_TAB
    jz .tab
    cmp edx, ASCII_NEWLINE
    jz .enter
    push edx
    call putchar
    add esp, 4
    jmp .return
.escape:
    push esc_str
    call printf
    add esp, 4
    jmp .return
.backspace:
    push bs_str
    call printf
    add esp, 4
    jmp .return
.tab:
    push tab_str
    call printf
    add esp, 4
    jmp .return
.enter:
    push enter_str
    call printf
    add esp, 4
    jmp .return
.non_ascii:
    push eax
    push unknown_str
    call printf
    add esp, 8
    jmp .return
.return:
    leave
    ret

unknown_str:        db "Scancode: %d", 0
esc_str:            db "Escape", 0
bs_str:             db "Backspace", 0
tab_str:            db "Tab", 0
enter_str:          db 10, 0
released_str:       db "Released", 0

scancodes1:
    db 0
    db ASCII_ESCAPE
    db '1'
    db '2'
    db '3'
    db '4'
    db '5'
    db '6'
    db '7'
    db '8'
    db '9'
    db '0'
    db '-'
    db '='
    db ASCII_BACKSPACE
    db ASCII_TAB
    db 'q'
    db 'w'
    db 'e'
    db 'r'
    db 't'
    db 'y'
    db 'u'
    db 'i'
    db 'o'
    db 'p'
    db '['
    db ']'
    db ASCII_NEWLINE
    db 0
    db 'a'
    db 's'
    db 'd'
    db 'f'
    db 'g'
    db 'h'
    db 'j'
    db 'k'
    db 'l'
    db ';'
    db 0
    db '`'
    db 0
    db '\'
    db 'z'
    db 'x'
    db 'c'
    db 'v'
    db 'b'
    db 'n'
    db 'm'
    db ','
    db '.'
    db '/'
    db 0
    db '*'
    db 0
    db ' '
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db '7'
    db '8'
    db '9'
    db '-'
    db '4'
    db '5'
    db '6'
    db '+'
    db '1'
    db '2'
    db '3'
    db '.'
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
scancodes1end:
