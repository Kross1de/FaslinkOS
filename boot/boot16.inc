;; 16 bit real mode
use16

public boot

org MBR_ENTRY

BUSY_LOOP_SIZE = 5000000

; Bit to set in special CPU register cr0
PROTECTED_MODE = 00000001b

REAL_STACK_SIZE = 128 ; Not big, but enough to call some basic functions

boot:
    jmp 0x0000:.flushcs

.flushcs:
    mov sp, real_stack_top

    push hello16_str
    call bios_print
    call busy_loop16
    call busy_loop16
    call busy_loop16
    call busy_loop16
    call busy_loop16

    ; Save boot disk in memory
    mov [disk], dl

    call bios_enable_a20
    test ax, ax
    jnz panic16

    mov al, BIOS_VIDEO_MODE
    mov ah, BIOS_VIDEO_SET_MODE
    int BIOS_VIDEO

    call bios_disk_read
    test ax, ax
    jnz panic16

    cli

    lgdt [gdt_pointer] ; load the gdt table

    mov eax, cr0
    or eax, PROTECTED_MODE ; set the protected mode bit on special CPU reg cr0
    mov cr0, eax

    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp CODE_SEG:second_sector ; long jump to the code segment

panic16:
    push panic16_str
    call bios_print
    ; TODO: print out registers
    ; TODO: print out call stack
    ; TODO: print out memory?
    ; fall through to halt
halt16:
    cli
    hlt

busy_loop16:
    mov eax, BUSY_LOOP_SIZE
.loop:
    test eax, eax
    je .return
    dec eax
    jmp .loop
.return:
    ret

include 'include/gdt.inc'
include 'include/mbr.inc'
include 'include/bios.inc'

disk:      db 0x0
panic16_str: db "PANIC", 0
hello16_str: db "Hello from real mode", 0

align 4
real_stack_bottom:
times REAL_STACK_SIZE db 0
real_stack_top:

times (MBR_SIZE - 2) - ($-$$) db 0
dw MBR_MAGIC

;; Second 512 byte sector
second_sector:
