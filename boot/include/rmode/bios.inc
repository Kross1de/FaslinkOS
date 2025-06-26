;; 16 bit real mode
use16

; BIOS functions used
BIOS_A20               = 0x15
BIOS_A20_CHECK_SUPPORT = 0x2403
BIOS_A20_CHECK_GATE    = 0x2402
BIOS_A20_ENABLE_GATE   = 0x2401

BIOS_VIDEO                = 0x10
BIOS_VIDEO_SET_MODE       = 0x00
BIOS_VIDEO_MODE           = 0x03
BIOS_WRITE_CHAR_TTY       = 0x0e

BIOS_DISK              = 0x13
BIOS_DISK_READ_SECTORS = 0x02

bios_enable_a20_or_error:
    ; The A20 gate allows us to read mode than 1MB
    mov ax, BIOS_A20_CHECK_SUPPORT
    int BIOS_A20
    jb .error
    cmp ah, 0
    jnz .error

    ; Check A20 gate status with BIOS
    mov ax, BIOS_A20_CHECK_GATE
    int BIOS_A20
    jb .error
    cmp ah, 0
    jnz .error

    cmp al, 1
    jz .a20_activated

    ; Activate A20 gate
    mov ax, BIOS_A20_ENABLE_GATE
    int BIOS_A20
    jb .error
    cmp ah, 0
    jnz .error

.error:
    push a20_error_str
    call bios_print
    call halt

.a20_activated:
    ret

bios_print:
    push bp
    mov bp, sp
    mov si, [bp + 4]

    mov ah, BIOS_WRITE_CHAR_TTY
.loop:
    lodsb
    or al,al
    jz .end
    int BIOS_VIDEO
    jmp .loop

.end:
    pop bp
    ret

a20_error_str: db "ERROR Enabling A20 Gate",0
