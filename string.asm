format elf
section '.text' executable
use32
public strnrev
public memcpy
public strlen

include 'include/kernel.inc'

strnrev:
	enter 0, 0
    push ebx
    push esi
    push edi

; args
str_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
n_offset = STACK_ARGS_OFFSET + 2 * WORD_SIZE
    
    xor eax, eax
    mov ecx, [ebp + n_offset]
    shr ecx, 1
.loop:
    mov edx, [ebp + str_offset]
    add edx, eax
    mov esi, edx
    xor edx, edx
    mov dl, [esi]
    mov ebx, [ebp + str_offset]
    add ebx, [ebp + n_offset]
    sub ebx, eax
    dec ebx
    mov edi, ebx
    xor ebx, ebx
    mov bl, [edi]
    mov [esi], bl
    mov [edi], dl
    inc eax
    cmp eax, ecx
    jge .return
    jmp .loop
.return:
    pop edi
    pop esi
    pop ebx
    leave
    ret

memcpy:
	enter 0, 0
    push esi
    push edi
    push ecx

; args
dest_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
src_offset = STACK_ARGS_OFFSET + 2 * WORD_SIZE
n_offset = STACK_ARGS_OFFSET + 3 * WORD_SIZE
    mov edi, [ebp + dest_offset]
    mov esi, [ebp + src_offset]
    mov ecx, [ebp + n_offset]
.loop:
    mov dl, [esi]
    mov [edi], dl
    inc esi
    inc edi
    dec ecx
    test ecx, ecx
    jz .return
    jmp .loop
.return:
    mov eax, [ebp + dest_offset]
    pop ecx
    pop edi
    pop esi
    leave
    ret

strlen:
    enter 0, 0
s_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
    xor eax, eax
    mov ecx, [ebp + str_offset]
.loop:
    cmp byte [ecx], 0
    jz .return
    inc ecx
.return:
    leave
    ret

itoa_alpha_str: db "0123456789abcdefghijklmnopqrstuvwxyz", 0
