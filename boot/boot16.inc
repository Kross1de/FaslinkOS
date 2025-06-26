;; 16 bit real mode
use16

public boot

org MBR_ENTRY

; Bit to set in special CPU register cr0
PROTECTED_MODE = 00000001b

REAL_STACK_SIZE = 128 ; Not big, but enough to call some basic functions

boot:
    jmp 0x0000:.flushcs

.flushcs:
    mov sp, real_stack_top

    ; Save boot disk in memory
    mov [disk], dl

    call bios_enable_a20_or_error

    mov al, BIOS_VIDEO_MODE
    mov ah, BIOS_VIDEO_SET_MODE
    int BIOS_VIDEO

    mov ah, BIOS_DISK_READ_SECTORS
    mov al, 1 ; sectors to read
    mov ch, 0 ; cylinder idx
    mov dh, 0 ; head idx
    mov cl, 2 ; sector idx (second 512 bytes)
    mov dl, [disk] ; disk idx
    mov bx, second_sector;
    int BIOS_DISK

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

halt:
    cli ; clear interrupt flag
    hlt ; halt execution

include 'include/gdt.inc'
include 'include/mbr.inc'
include 'include/bios.inc'

disk:      db 0x0

align 4
real_stack_bottom:
times REAL_STACK_SIZE db 0
real_stack_top:

times (MBR_SIZE - 2) - ($-$$) db 0
dw MBR_MAGIC

;; Second 512 byte sector
second_sector:
