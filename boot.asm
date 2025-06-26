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
	BIOS_A20_CHECK_SUPPORT	= 0x2403
	BIOS_A20_CHECK_GATE	= 0x2402
	BIOS_A20_ENABLE_GATE	= 0x2401
	
	BIOS_VIDEO		= 0x10
	BIOS_SET_VIDEO_MODE	= 0x00
	BIOS_VIDEO_MODE		= 0x03
	BIOS_WRITE_CHAR_TTY	= 0x0e

	PROTECTED_MODE		= 00000001b

boot:
	mov ax, BIOS_A20_CHECK_SUPPORT
	int BIOS_A20
	jb error
	cmp ah, 0
	jnz error

	mov ax, BIOS_A20_CHECK_GATE
	int BIOS_A20
	jb error
	cmp ah, 0
	jnz error

	cmp al, 1
	jz .a20_activated

	;; Activate A20 gate
	mov ax, BIOS_A20_ENABLE_GATE
	int BIOS_A20
	jb error
	cmp ah, 0
	jnz error

	.a20_activated:
	mov al, BIOS_VIDEO_MODE
	mov ah, BIOS_SET_VIDEO_MODE
	int BIOS_VIDEO

	cli
	lgdt [gdt_pointer]	; load the GDT table
	mov eax, cr0
	or eax, PROTECTED_MODE
	mov cr0, eax

	jmp CODE_SEG:boot32

error:
	mov si, error_str
	jmp bios_print_and_halt

bios_print_and_halt:
	mov ah, BIOS_WRITE_CHAR_TTY
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

	GDT_BASE_LOW		= 0x0
	GDT_BASE_MID		= 0x0
	GDT_BASE_HIGH		= 0x0
	GDT_LIMIT_LOW		= 0xFFFF
	GDT_LIMIT_HIGH		= 0xF
	GDT_ACCESS_PRESENT	= 10000000b
	GDT_ACCESS_SYSTEM	= 00010000b
	GDT_ACCESS_EXECUTABLE	= 00001000b
	GDT_ACCESS_RW		= 00000010b
	GDT_FLAG_GRANULARITY	= 10000000b
	GDT_FLAG_SIZE		= 01000000b

gdt_start:
	dq 0x0
gdt_code:
	dw GDT_LIMIT_LOW
	dw GDT_BASE_LOW
	db GDT_BASE_MID
	db GDT_ACCESS_PRESENT or GDT_ACCESS_SYSTEM or GDT_ACCESS_RW or GDT_ACCESS_EXECUTABLE
	db GDT_FLAG_GRANULARITY or GDT_FLAG_SIZE or GDT_LIMIT_HIGH
	db GDT_BASE_HIGH
gdt_data:
	dw GDT_LIMIT_LOW
	dw GDT_BASE_LOW
	db GDT_BASE_MID
	db GDT_ACCESS_PRESENT or GDT_ACCESS_SYSTEM or GDT_ACCESS_RW
	db GDT_FLAG_GRANULARITY or GDT_FLAG_SIZE or GDT_LIMIT_HIGH
	db GDT_BASE_HIGH
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
	jmp vga_print_and_halt

vga_print_and_halt:
	mov ebx, VGA_BUFFER
	mov ah, 4
	.loop:
	lodsb
	or al, al
	jz halt32
	or eax, 0x0100
	mov word [ebx], ax
	add ebx, 2
	jmp .loop
halt32:
	cli
	hlt

hello_str:	db "PROTECTED MODE!", 0
error_str:	db "ERROR", 0

	times (MBR_SIZE - 2) - ($-$$) db 0
	dw MBR_MAGIC
