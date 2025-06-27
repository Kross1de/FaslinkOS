#include "include/vga.h"
#include "include/string.h"

void kmain() {
    vga_puts("Hello from kernel.c\n");
    char itoa_buf[33];
    char *str = itoa(0x1337BABE, itoa_buf, 16);
    if (str == 0) {
        vga_puts("itoa failed\n");
    } else {
        vga_puts(str);
        vga_putnl();
    }
}
