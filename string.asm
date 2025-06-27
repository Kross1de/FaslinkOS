format elf
section '.text' executable
;; 32 bit protected mode
use32
public itoa

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

    ; TODO: reverse string
    ; maybe make a strnrev (and strrev which calls that with strlen?)

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

itoa_err_str: db "Error: itoa() failed", 10, 0
itoa_alpha_str: db "0123456789abcdefghijklmnopqrstuvwxyz", 0
