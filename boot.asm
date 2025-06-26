	org 0x7c00
boot:
	mov si, hello		; point si register to hello msg
	mov ah, 0x0e
	.loop:
	lodsb
	or al, al 		; is al == 0 ?
	jz halt 		; if (al == 0) jump to halt label
	int 0x10		; calling BIOS interrupt
	jmp .loop
halt:
	cli			; clear interrupt flag
	hlt			; halt execution
hello:	db "Hello, world!", 0

	times 510 - ($-$$) db 0	; pad remaining 510 bytes with zero
	dw 0xaa55		; magic BIOS number
