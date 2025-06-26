;; 32 bit protected mode
use32

extrn kmain

boot32:
    mov esp, kernel_stack_top
    call kmain
    cli
    hlt