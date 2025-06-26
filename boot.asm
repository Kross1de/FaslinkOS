	;; BIOS functions
	BIOS_A20		= 0x15
	A20_CHECK_SUPPORT	= 0x2403
	A20_CHECK_GATE		= 0x2402
	A20_ENABLE_GATE		= 0x2401
	
	BIOS_VIDEO		= 0x10
	WRITE_CHAR_TTY		= 0x0e

	;; MBR
	MBR_SIZE		= 512
	MBR_MAGIC		= 0xaa55

	org 0x7c00
boot:
	mov ax, A20_CHECK_SUPPORT
	int BIOS_A20
	jb .error
	cmp ah, 0
	jnz .error

	cmp al, 1
	jz .a20_activated

	;; Activate A20 gate
	mov ax, A20_ENABLE_GATE
	int BIOS_A20
	jb .error
	cmp ah, 0
	jnz .error

	.a20_activated:
	mov si, hello
	jmp .print_and_halt

	.error:
	mov si, error

	.print_and_halt:
	mov ah, WRITE_CHAR_TTY
	.loop:
	lodsb
	or al, al
	jz halt
	int BIOS_VIDEO
	jmp .loop
halt:
	cli			; clear interrupt flag
	hlt			; halt execution
hello:	db "Hello, world!", 0
error:	db "ERROR", 0

	times (MBR_SIZE - 2) - ($-$$) db 0
	dw MBR_MAGIC
