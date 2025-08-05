use32

extrn kmain
extrn vga_init
extrn printf
extrn pic_init
public panic
public halt
public busy_loop

MAGIC = 0x1abcdef9
IDT_SIZE = 32 + 16

boot32:
    jmp .start
    dd magic
    dd int3_handler
    dd busy_loop
.start:
    mov esp, kernel_stack_top
    call vga_init

    cmp dword [magic], MAGIC
    je .magic_correct
    pushd magic - 0x7e00
    pushd magic
    push kmain_magic_str
    call printf
    add esp, 4
    jmp panic

.magic_correct:
    call idt_init
    call pic_init
    sti

    call kmain
    push kmain_fallout_str
    call printf
    add esp, 4
panic:
panic32:
    pusha
    push panic32_str
    call printf
    add esp, 4
    push dump_regs_fmt_str
    call printf
    popa
    ; TODO: print out call stack
    ; TODO: print out memory?
    ; fall through to halt
halt:
halt32:
    cli
    hlt
    jmp halt

busy_loop:
busy_loop32:
    mov eax, BUSY_LOOP_SIZE
.loop:
    test eax, eax
    je .return
    dec eax
    jmp .loop
.return:
    ret

include 'include/idt.inc'

panic32_str:        db "PANIC", 10, 0
kmain_fallout_str:  db "ERROR: unexpected return from kmain", 10, 0
kmain_magic_str:    db "ERROR: could not read all source code, magic: %p, diff: %p", 10, 0
dump_regs_fmt_str:  db "eax: %#010x", 10
                    db "ecx: %#010x", 10
                    db "edx: %#010x", 10
                    db "ebx: %#010x", 10
                    db "esp: %#010x", 10
                    db "ebp: %#010x", 10
                    db "esi: %#010x", 10
                    db "edi: %#010x", 10
                    db 0

section '.magic'
public magic
magic:
dd MAGIC
