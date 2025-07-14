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
include 'include/string.inc'

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
    mov esi, [ebp + STACK_ARGS_OFFSET + WORD_SIZE]
    mov ebx, ebp
    add ebx, STACK_ARGS_OFFSET + 2 * WORD_SIZE  ; current arg index
    ; TODO: check for null
.loop:
    lodsb
    or al, al
    jz .return
    cmp eax, '%'
    je .percent
    push eax
    call putchar
    add esp, WORD_SIZE
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
    pushd [ebx]
    call puts
    add esp, WORD_SIZE
    add ebx, WORD_SIZE
    jmp .loop
.percent_x:
    push 16
    jmp .itoa_puts 
.percent_o:
    push 8
    jmp .itoa_puts
.percent_d:
    push 10
    jmp .itoa_puts
.itoa_puts:
    push itoa_temp_str
    pushd [ebx]
    call itoa
    add esp, 3*WORD_SIZE
    push eax
    call puts
    add ebx, WORD_SIZE
    jmp .loop
.percent_u:
    push 10
    push itoa_temp_str
    pushd [ebx]
    call utoa
    add esp, 3*WORD_SIZE
    push eax
    call puts
    add ebx, WORD_SIZE
    jmp .loop
.percent_percent:
    pushd '%'
    call putchar
    add esp, WORD_SIZE
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
itoa_temp_str: times 33 db 0
