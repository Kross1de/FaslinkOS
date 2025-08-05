; TODO: place it to right place for this
public idt_add_entry

div_by_0:
int0_handler:
    pushd div_by_0_str
    call printf
    add esp, 4
    jmp panic

breakpoint:
int3_handler:
    iret

double_fault:
int8_handler:
    pushd double_fault_str
    call printf
    add esp, 4
    jmp panic

idt_init:
    lidt [idt_pointer]

    pushd int0_handler
    pushd 0
    call idt_add_entry
    add esp, 8

    pushd int3_handler
    pushd 3
    call idt_add_entry
    add esp, 8

    pushd int8_handler
    pushd 8
    call idt_add_entry
    add esp, 8

    ret

idt_add_entry:
    enter 0, 0
    mov ecx, [ebp + 8]
    shl ecx, 3
    add ecx, idt_start
    cmp ecx, idt_end
    jge .error
    cmp ecx, idt_start
    jl .error
    mov eax, [ebp + 12]
    mov [ecx], ax
    mov word [ecx + 2], CODE_SEG
    mov byte [ecx + 4], 0
    mov byte [ecx + 5], 0x8E
    shr eax, 16
    mov word [ecx + 6], ax
    leave
    ret

.error:
    push dword [ebp + 8]
	push idt_oob_str
	call printf
	add esp, 4
	jmp panic

idt_start:
    times IDT_SIZE dq 0
idt_end:
idt_pointer:
  dw idt_end - idt_start
  dd idt_start

div_by_0_str: 			db 10, "EXCEPTION: Division By 0", 10, 0
double_fault_str: 		db 10, "EXCEPTION: Double Fault", 10, 0
idt_oob_str: 			db "ERROR: idt_add_trap_entry called with out of bounds index %d", 10, 0
