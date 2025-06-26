; Global Descriptor Table

GDT_BASE_LOW          = 0x0
GDT_BASE_MID          = 0x0
GDT_BASE_HIGH         = 0x0
GDT_LIMIT_LOW         = 0xFFFF
GDT_LIMIT_HIGH        = 0xF
GDT_ACCESS_PRESENT    = 10000000b
GDT_ACCESS_SYSTEM     = 00010000b
GDT_ACCESS_EXECUTABLE = 00001000b
GDT_ACCESS_RW         = 00000010b
GDT_FLAG_GRANULARITY  = 10000000b
GDT_FLAG_SIZE         = 01000000b

gdt_start:
    dq 0x0
gdt_code:
    dw GDT_LIMIT_LOW
    dw GDT_BASE_LOW
    db GDT_BASE_MID
    db GDT_ACCESS_PRESENT or GDT_ACCESS_SYSTEM or GDT_ACCESS_RW or GDT_ACCESS_EXECUTABLE
    db GDT_FLAG_GRANULARITY or GDT_FLAG_SIZE or GDT_LIMIT_HIGH
    db GDT_BASE_HIGH
gdt_data:
    dw GDT_LIMIT_LOW
    dw GDT_BASE_LOW
    db GDT_BASE_MID
    db GDT_ACCESS_PRESENT or GDT_ACCESS_SYSTEM or GDT_ACCESS_RW
    db GDT_FLAG_GRANULARITY or GDT_FLAG_SIZE or GDT_LIMIT_HIGH
    db GDT_BASE_HIGH
gdt_end:
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
CODE_SEG = gdt_code - gdt_start
DATA_SEG = gdt_data - gdt_start
