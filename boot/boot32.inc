;; 32 bit protected mode
use32

extrn kmain
extrn vga_init
extrn vga_puts
public panic
public halt
public busy_loop

boot32:
    mov esp, kernel_stack_top
    call vga_init
    call kmain
panic:
panic32:
;    push panic_str
;    call vga_puts
    ; TODO: print out registers
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
