;; 32 bit protected mode
use32

extrn kmain
extrn vga_init
extrn printf
public panic
public halt
public busy_loop

boot32:
    mov esp, kernel_stack_top
    call vga_init
    call kmain
panic:
panic32:
    push panic32_str
    call printf
    add esp, 4
    pusha
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
dump_regs_fmt_str:  db "eax: 0x%x", 10
                    db "ecx: 0x%x", 10
                    db "edx: 0x%x", 10
                    db "ebx: 0x%x", 10
                    db "esp: 0x%x", 10
                    db "ebp: 0x%x", 10
                    db "esi: 0x%x", 10
                    db "edi: 0x%x", 10
                    db 0
