format elf
section '.bss'

public kernel_stack_top

align 4
kernel_stack_bottom:
times 16384 db 0; 16 KB
kernel_stack_top:
