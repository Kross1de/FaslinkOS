	format binary as "bin"

	;; MBR
	MBR_SIZE		= 512
	MBR_MAGIC		= 0xaa55
	MBR_ENTRY		= 0x7c00

	org MBR_ENTRY

	;; 16 bit real mode
	use16
	
	;; BIOS functions
	BIOS_A20		= 0x15
	A20_CHECK_SUPPORT	= 0x2403
	A20_CHECK_GATE		= 0x2402
	A20_ENABLE_GATE		= 0x2401
	
	BIOS_VIDEO		= 0x10
	SET_VIDEO_MODE		= 0x00
	VIDEO_MODE		= 0x03
	WRITE_CHAR_TTY		= 0x0e

boot:
	mov ax, A20_CHECK_SUPPORT
	int BIOS_A20
	jb error
	cmp ah, 0
	jnz error

	cmp al, 1
	jz .a20_activated

	;; Activate A20 gate
	mov ax, A20_ENABLE_GATE
	int BIOS_A20
	jb error
	cmp ah, 0
	jnz error

	.a20_activated:
	mov al, VIDEO_MODE
	mov ah, SET_VIDEO_MODE
	int BIOS_VIDEO

	cli
	lgdt [gdt_pointer]	; load the GDT table
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODE_SEG:boot32

error:
	mov si, error_str
	jmp print_and_halt

print_and_halt:
	mov ah, WRITE_CHAR_TTY
	mov bl, 0
	.loop:
	lodsb
	or al, al
	jz halt
	int BIOS_VIDEO
	inc bl
	jmp .loop
halt:
	cli			; clear interrupt flag
	hlt			; halt execution

	;; Global Descriptor Table

gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start
	CODE_SEG = gdt_code - gdt_start
	DATA_SEG = gdt_data - gdt_start

	;; 32 bit protected mode
	use32

	VGA_BUFFER = 0xb8000

boot32:
	;; WE IN PROTECTED MODE HELLL YEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...

	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esi, hello_str
	jmp print_and_halt32

print_and_halt32:
	mov ebx, VGA_BUFFER
	mov ah, 0
	.loop:
	lodsb
	or al, al
	jz halt
	or eax, 0x0100
	mov word [ebx], ax
	inc ah
	add ebx, 2
	jmp .loop
halt32:
	cli
	hlt

hello_str:	db "PROTECTED MODE!", 0
error_str:	db "ERROR", 0

	times (MBR_SIZE - 2) - ($-$$) db 0
	dw MBR_MAGIC
