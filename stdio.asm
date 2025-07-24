format elf
section '.text' executable
use32
public puts
public putchar
public putnl
public printf

include 'include/kernel.inc'
include 'include/vga.inc'
include 'include/stdlib.inc'
include 'include/ctype.inc'
include 'include/string.inc'

puts:
    jmp vga_puts

putchar:
    jmp vga_putchar

putnl:
    jmp vga_putnl

printf:
    enter WORD_SIZE, 0
    push esi
    push ebx

; args
format_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
va_args_offset =STACK_ARGS_OFFSET + 2 * WORD_SIZE
; variables
width_offset = -1 * 1 * WORD_SIZE

    xor eax, eax
    mov esi, [ebp + format_offset]
    mov ebx, ebp
    add ebx, va_args_offset  ; current arg index
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
.width_check:
    ; TODO: check if non-0 digit, if so it is a field width
    ; needs atoi, or strtol
    push eax
    mov word [ebp + width_offset], 0
    push eax
    call isdigit
    add esp, 4
    test eax, eax
    pop eax
    jz .conversion_specifiers
    ; TODO: check if digit is 0
    dec esi
    push esi
    inc esi
    call atoi
    mov [ebp + width_offset], eax
.skip_digits_loop:
    lodsb
    or al, al
    jz .error
    push eax
    push eax
    call isdigit
    add esp, 4
    test eax, eax
    pop eax
    jnz .skip_digits_loop
.conversion_specifiers:
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
    add ebx, WORD_SIZE
    jmp .puts_with_length
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
    add ebx, WORD_SIZE
    call itoa
    add esp, 3*WORD_SIZE
    push eax
    jmp .puts_with_length
.percent_u:
    push 10
    push itoa_temp_str
    pushd [ebx]
    add ebx, WORD_SIZE
    call utoa
    add esp, 3*WORD_SIZE
    push eax
    jmp .puts_with_length
.puts_with_length:
    push dword [esp]
    call strlen
    add esp, WORD_SIZE
    sub [ebp + width_offset], eax
.width_loop:
    cmp dword [ebp + width_offset], 0
    jle .puts
    push ' '
    call putchar
    add esp, WORD_SIZE
    dec dword [ebp + width_offset]
    jmp .width_loop
.puts:
    call puts
    add esp, WORD_SIZE
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
