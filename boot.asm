	;; BIOS functions
	BIOS_VIDEO	= 0x10
	WRITE_CHAR_TTY	= 0x0e

	;; MBR
	MBR_SIZE	= 512
	MBR_MAGIC	= 0xaa55

	org 0x7c00
boot:
	mov si, hello
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

	times (MBR_SIZE - 2) - ($-$$) db 0
	dw MBR_MAGIC
