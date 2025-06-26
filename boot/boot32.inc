;; 32 bit protected mode
use32

extrn kmain
extrn vga_init
extrn vga_print

boot32:
    mov esp, kernel_stack_top
    call vga_init
    call kmain
panic32:
    push panic_str
    call vga_print
    ; TODO: print out registers
    ; TODO: print out call stack
    ; TODO: print out memory?
    ; fall through to halt
halt32:
    cli
    hlt
