use32

extrn kmain
extrn vga_init
extrn printf
public panic
public halt
public busy_loop

MAGIC = 0x1abcdef9

boot32:
    jmp .start
    dd kmain
    dd printf
    extrn atoi
    dd atoi
.start:
    mov esp, kernel_stack_top
    call vga_init

    cmp dword [magic], MAGIC
    je .magic_correct
    push kmain_magic_str
    call printf
    add esp, 4
    jmp panic

.magic_correct:
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

panic32_str:        db "PANIC", 10, 0
kmain_fallout_str:  db "ERROR: unexpected return from kmain", 10, 0
kmain_magic_str:    db "ERROR: could not read all source code", 10, 0
dump_regs_fmt_str:  db "eax: 0x%08x", 10
                    db "ecx: 0x%08x", 10
                    db "edx: 0x%08x", 10
                    db "ebx: 0x%08x", 10
                    db "esp: 0x%08x", 10
                    db "ebp: 0x%08x", 10
                    db "esi: 0x%08x", 10
                    db "edi: 0x%08x", 10
                    db 0

section '.magic'
public magic
magic:
dd MAGIC
