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
    enter 4 * WORD_SIZE, 0
    push esi
    push ebx

; args
format_offset       = STACK_ARGS_OFFSET + 1 * WORD_SIZE
va_args_offset      = STACK_ARGS_OFFSET + 2 * WORD_SIZE
; variables
width_offset        = -1 * 1 * WORD_SIZE
padding_c_offset    = -1 * 2 * WORD_SIZE
padding_order_offset= -1 * 3 * WORD_SIZE
prefix_offset       = -1 * 4 * WORD_SIZE

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
    mov dword [ebp + padding_c_offset], ' '
    mov dword [ebp + padding_order_offset], 0
    mov dword [ebp + prefix_offset], empty_str
.flags:
    ; read another char
    lodsb
    or al, al
    jz .error   ; Expected another char
    cmp eax, '0'
    je .zero_padding_flag
    cmp eax, '#'
    je .alternate_form_flag
    cmp eax, '-'
    je .left_justified_flag
    cmp eax, ' '
    je .space_flag
    cmp eax, '+'
    je .positive_flag
    jmp .field_width
.zero_padding_flag:
    cmp dword [ebp + padding_order_offset], 2
    je .flags
    mov dword [ebp + padding_c_offset], '0'
    cmp dword [ebp + prefix_offset], 0
    jne .flags
    mov dword [ebp + padding_order_offset], 1
    jmp .flags
.alternate_form_flag:
    mov dword [ebp + prefix_offset], 0
    cmp dword [ebp + padding_c_offset], '0'
    jne .flags
    mov dword [ebp + padding_order_offset], 1
    jmp .flags
.left_justified_flag:
    mov dword [ebp + padding_order_offset], 2
    mov dword [ebp + padding_c_offset], ' '
    jmp .flags
.space_flag:
.positive_flag:
    ; TODO
    jmp .error

.field_width:
    ; TODO: check if non-0 digit, if so it is a field width
    ; needs atoi, or strtol
    push eax
    mov dword [ebp + width_offset], 0
    push eax
    call isdigit
    add esp, 4
    test eax, eax
    pop eax
    jz .precision
.chop_width:
    dec esi
    push esi
    inc esi
    call atoi
    mov [ebp + width_offset], eax
.chop_width_loop:
    lodsb
    or al, al
    jz .error
    push eax
    push eax
    call isdigit
    add esp, 4
    test eax, eax
    pop eax
    jnz .chop_width_loop

.precision:
    ; TODO
.length_modifier:
    ; TODO
.conversion_specifiers:
    cmp eax, 's'
    je .percent_s
    cmp eax, 'x'
    je .percent_x
    cmp eax, 'X'
    je .percent_x
    cmp eax, 'o'
    je .percent_o
    cmp eax, 'd'
    je .percent_d
    cmp eax, 'i'
    je .percent_i
    cmp eax, 'u'
    je .percent_u
    cmp eax, 'c'
    je .percent_c
    cmp eax, 'p'
    je .percent_p
    cmp eax, '%'
    je .percent_percent
    ; TODO: add stubs
    ; Invalid escape code
    jmp .error
.percent_s:
    pushd [ebx]
    add ebx, WORD_SIZE
    jmp .puts_with_length
.percent_x:
    push 16
    cmp dword [ebp + prefix_offset], 0
    je .percent_x_alternate
    jmp .itoa_puts
.percent_x_alternate:
    mov dword [ebp + prefix_offset], hex_prefix_str
    jmp .itoa_puts 
.percent_o:
    push 8
    cmp dword [ebp + prefix_offset], 0
    je .percent_o_alternate
    jmp .itoa_puts
.percent_o_alternate:
    mov dword [ebp + prefix_offset], octal_prefix_str
    jmp .itoa_puts
.percent_d:
.percent_i:
    push 10
    jmp .itoa_puts
.percent_X:
    push 16
    push itoa_temp_str
    pushd [ebx]
    add ebx, WORD_SIZE
    call itoA
    add esp, 3*WORD_SIZE
    push eax
    cmp dword [ebp + prefix_offset], 0
    je .percent_X_alternate
    jmp .puts_with_length
.percent_X_alternate:
    mov dword [ebp + prefix_offset], hex_prefix_str
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
.percent_p:
    mov dword [ebp + prefix_offset], 0
    jmp .percent_x
.percent_c:
    ; TODO: putchar with width
    pushd [ebx]
    add ebx, WORD_SIZE
    call putchar
    add esp, WORD_SIZE
    jmp .loop
.percent_percent:
    pushd '%'
    call putchar
    add esp, WORD_SIZE
    jmp .loop

.itoa_puts:
    push itoa_temp_str
    pushd [ebx]
    add ebx, WORD_SIZE
    call itoa
    add esp, 3*WORD_SIZE
    push eax
    jmp .puts_with_length
.puts_with_length:
    ; TODO: assert if padding_order_offset is out of range
    cmp dword [ebp + padding_order_offset], 0
    jl .error
    cmp dword [ebp + padding_order_offset], 2
    jg .error

    cmp dword [ebp + padding_order_offset], 0
    jne .puts_prefix
    call .padding
.puts_prefix:
    push dword [ebp + prefix_offset]
    call puts
    add esp, WORD_SIZE
    dec dword [ebp + padding_order_offset]
    cmp dword [ebp + padding_order_offset], 0
    jne .puts
    call .padding
.puts:
    call puts
    add esp, WORD_SIZE
    dec dword [ebp + padding_order_offset]
    cmp dword [ebp + padding_order_offset], 0
    jne .loop
    sub esp, WORD_SIZE
    call .padding
    add esp, WORD_SIZE
    jmp .loop

.padding:
    push dword [ebp + prefix_offset]
    call strlen
    add esp, WORD_SIZE
    sub [ebp + width_offset], eax
    pushd [esp + 4]
    call strlen
    add esp, WORD_SIZE
    sub [ebp + width_offset], eax
.padding_loop:
    cmp dword [ebp + width_offset], 0
    jle .end_padding
    push dword [ebp + padding_c_offset]
    call putchar
    add esp, WORD_SIZE
    dec dword [ebp + width_offset]
    jmp .padding_loop
.end_padding:
    ret

.error:
    ; TODO: diff error cases
    mov eax, -1
.return:
    pop ebx
    pop esi
    leave
    ret

itoa_temp_str: times 33 db 0
empty_str: db "", 0
hex_prefix_str: db "0x", 0
octal_prefix_str: db "0", 0
