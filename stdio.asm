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
    push esi
    push ebx
    xor eax, eax
    mov esi, [ebp + 8]
    ; TODO: check for null
.loop:
    lodsb
    or al, al
    jz .return
    cmp eax, '%'
    je .percent
    push eax
    call vga_putchar
    jmp .loop
    mov eax, 0
    jmp .return
.percent:
    lodsb
    or al, al
    jz .error   ; Expected another char
    cmp eax, 's'
    je .percent_s
    cmp eax, 'x'
    je .percent_x
    cmp eax, 'o'
    je .percent_o
    cmp eax, 'd'
    je .percent_d
    cmp eax, 'u'
    je .percent_u
    cmp eax, '%'
    je .percent_percent
    ; Invalid escape code
    jmp .error
.percent_s:
    push unimplemented_str
    call puts
    jmp .error
    jmp .loop
.percent_x:
    push unimplemented_str
    call puts
    jmp .error
    jmp .loop
.percent_o:
    push unimplemented_str
    call puts
    jmp .error
    jmp .loop
.percent_d:
    push unimplemented_str
    call puts
    jmp .error
    jmp .loop
.percent_u:
    push unimplemented_str
    call puts
    jmp .error
    jmp .loop
.percent_percent:
    pushd '%'
    call putchar
    jmp .loop
.error:
    ; TODO: diff error cases
    mov eax, -1
.return:
    pop ebx
    pop esi
    leave
    ret

unimplemented_str: db "UNIMPLEMENTED", 10, 0