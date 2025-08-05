format elf
section '.text' executable
use32
public pic_init

extrn idt_add_entry

PIC1_COMMAND		= 0x20
PIC1_DATA			= 0x21
PIC2_COMMAND		= 0xA0
PIC2_DATA			= 0xA1
PIC_EOI				= 0x20
ICW1_ICW4			= 0x01
ICW1_SINGLE			= 0x02
ICW1_INTERVAL4		= 0x04
ICW1_LEVEL			= 0x08
ICW1_INIT			= 0x10
ICW4_8086			= 0x01
ICW4_AUTO			= 0x02
ICW4_BUF_SECONDARY	= 0x08
ICW4_BUF_PRIMARY	= 0x0C
ICW4_SFNM			= 0x10
PIC1_OFFSET			= 0x20
PIC2_OFFSET			= 0x28

TIMER				= 0
KEYBOARD			= 1

timer_handler:
	pusha
	pushd TIMER
	call pic_send_eoi
	add esp, 4
	popa
	iret

pic_send_eoi:
	enter 0, 0
	cmp dword [ebp + 8], 8
	jl .send_primary
	mov al, PIC_EOI
	out PIC2_COMMAND, al
.send_primary:
	mov al, PIC_EOI
	out PIC1_COMMAND, al
	leave
	ret

pic_init:
	call pic_initialize
	; setup handlers
	push timer_handler
	push PIC1_OFFSET + TIMER
	call idt_add_entry
	add esp, 8
	ret

pic_initialize:
	enter 0, 0
	in al, PIC1_DATA
	push eax
	in al, PIC2_DATA
	push eax

	mov al, ICW1_INIT or ICW1_ICW4
	out PIC1_COMMAND, al
	xor al, al
	out 0x80, al

	mov al, ICW1_INIT or ICW1_ICW4
	out PIC2_COMMAND, al
	xor al, al
	out 0x80, al

	mov al, PIC1_OFFSET
	out PIC1_DATA, al
	xor al, al
	out 0x80, al

	mov al, PIC2_OFFSET
	out PIC2_DATA, al
	xor al, al
	out 0x80, al

	mov al, 4
	out PIC1_DATA, al
	xor al, al
	out 0x80, al

	mov al, 2
	out PIC2_DATA, al
	xor al, al
	out 0x80, al

	mov al, ICW4_8086
	out PIC1_DATA, al
	xor al, al
	out 0x80, al

	mov al, ICW4_8086
	out PIC2_DATA, al
	xor al, al
	out 0x80, al

	pop eax
	out PIC2_DATA, al
	pop eax
	out PIC1_DATA, al
	leave
	ret