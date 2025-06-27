#include "include/vga.h"
#include "include/string.h"

void cFn() {
    char itoa_buf[33];
    vga_puts("Printing test from idk.c\n");
    for (int i = 0; i < 255; i++) {
        vga_puts(itoa(i, itoa_buf, 10));
        vga_putnl();
    }
}
