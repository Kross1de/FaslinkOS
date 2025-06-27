format elf
section '.text' executable
;; 32 bit protected mode
use32
public itoa
public strnrev

include 'include/kernel.inc'
include 'include/vga.inc'

itoa:
    push ebp
    mov ebp, esp

; args
num_offset = STACK_ARGS_OFFSET + 1 * WORD_SIZE
str_offset = STACK_ARGS_OFFSET + 2 * WORD_SIZE
base_offset = STACK_ARGS_OFFSET + 3 * WORD_SIZE
; variables
p_offset = -1 * 1 * WORD_SIZE
VAR_SIZE = 1 * WORD_SIZE

    ; TODO, check base is less than 36
    mov eax, [ebp + str_offset]
    test eax, eax
    jz .error
    sub esp, VAR_SIZE
    mov eax, [ebp + str_offset]
    mov [ebp + p_offset], eax
.divmod_loop:
    mov edx, 0
    mov eax, [ebp + num_offset]
    mov ecx, [ebp + base_offset]
    div ecx
    mov [ebp + num_offset], eax
    mov eax, itoa_alpha_str
    add eax, edx
    mov dl, [eax]
    mov eax, [ebp + p_offset]
    mov [eax], dl
    inc eax
    mov [ebp + p_offset], eax
    mov eax, [ebp + num_offset]
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
    push itoa_err_str
    call vga_puts
    mov eax, 0
.return:
    mov esp, ebp
    pop ebp
    ret

strnrev:
    push ebp
    mov ebp, esp
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
    mov esp, ebp
    pop ebp
    ret

itoa_err_str: db "Error: itoa() failed", 10, 0
itoa_alpha_str: db "0123456789abcdefghijklmnopqrstuvwxyz", 0
