format elf
section '.boot32' executable

;; 32 bit protected mode
use32

extrn kmain
extrn kernel_stack_top

boot32:
    mov esp, kernel_stack_top
    call kmain
    cli
    hlt

include 'include/pmode/vga.inc'