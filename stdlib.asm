format elf
section '.text' executable
use32
public itoa
public utoa
public atoi

include 'include/kernel.inc'
include 'include/string.inc'
include 'include/stdio.inc'
include 'include/ctype.inc'

unsigned_flag_offset = -1 * 2 * WORD_SIZE
utoa:
    enter 2 * WORD_SIZE, 0
    mov dword [ebp + unsigned_flag_offset], 0
    jmp _itoa
itoa:
	enter 2 * WORD_SIZE, 0
    mov dword [ebp + unsigned_flag_offset], 0
    jmp _itoa
_itoa:

; args
value_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
str_offset = STACK_ARGS_OFFSET + 2 * WORD_SIZE
base_offset = STACK_ARGS_OFFSET + 3 * WORD_SIZE
; variables
p_offset = -1 * 1 * WORD_SIZE

    mov eax, [ebp + base_offset]
    cmp eax, 2
    jl .error
    cmp eax, 36
    jg .error
    mov eax, [ebp + unsigned_flag_offset]
    and eax, eax
    jnz .not_if_base10_neg
    mov eax, [ebp + base_offset]
    cmp eax, 10
    jnz .not_if_base10_neg
    mov eax, [ebp + value_offset]
    cmp eax, 0
    jge .not_if_base10_neg
	
    neg eax
    mov ecx, [ebp + str_offset]
    mov byte [ecx], '-'
    inc ecx
    pushd [ebp + base_offset]
    push ecx
    push eax
    call itoa
    add esp, 3*WORD_SIZE
    mov eax, [ebp + str_offset]
    jmp .return
.not_if_base10_neg:
    mov eax, [ebp + str_offset]
    test eax, eax
    jz .error
    mov eax, [ebp + str_offset]
    mov [ebp + p_offset], eax
.divmod_loop:
    mov edx, 0
    mov eax, [ebp + value_offset]
    mov ecx, [ebp + base_offset]
    div ecx
    mov [ebp + value_offset], eax
    mov eax, itoa_alpha_str
    add eax, edx
    mov dl, [eax]
    mov eax, [ebp + p_offset]
    mov [eax], dl
    inc eax
    mov [ebp + p_offset], eax
    mov eax, [ebp + value_offset]
    test eax, eax
    jz .end_loop
    jmp .divmod_loop
.end_loop:
    mov eax, [ebp + p_offset]
    mov dword [eax], 0
    sub eax, [ebp + str_offset]
    push eax
    pushd [ebp + str_offset]
    call strnrev
    add esp, 2*WORD_SIZE
    mov eax, [ebp + str_offset]
    jmp .return
.error:
    mov eax, 0
.return:
    leave
    ret

atoi:
str_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
    enter 0, 0
    push ebx
    push esi
    mov esi, [ebp + str_offset]
    mov ecx, 0
.loop:
    xor eax, eax
    lodsb
    or al, al
    jz .return
    mov ebx, eax
    push eax
    call isdigit
    add esp, WORD_SIZE
    test eax, eax
    jz .return
    sub ebx, '0'
    mov eax, 10
    xchg eax, ecx
    mul ecx
    add eax, ebx
    xchg eax, ecx
    jmp .loop
.return:
    mov eax, ecx
    pop esi
    pop ebx
    leave
    ret

itoa_alpha_str: db "0123456789abcdefghijklmnopqrstuvwxyz", 0
