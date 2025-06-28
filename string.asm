format elf
section '.text' executable
;; 32 bit protected mode
use32
public itoa
public strnrev
public memcpy

include 'include/kernel.inc'
include 'include/vga.inc'

itoa:
	enter 1 * WORD_SIZE, 0

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
    ; TODO: check if base is 10 and value is -ve
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

    mov eax, [ebp + str_offset]
    jmp .return
.error:
    ; TODO: At some point we shouldn't print out
    push itoa_err_str
    call vga_puts
    mov eax, 0
.return:
	leave
    ret

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

itoa_err_str: db "Error: itoa() failed", 10, 0
itoa_alpha_str: db "0123456789abcdefghijklmnopqrstuvwxyz", 0
