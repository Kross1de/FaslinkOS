#include "include/stdio.h"
#include "include/stdlib.h"

void kmain() {
    puts("Hello from kernel.c\n");
    char itoa_buf[33];
    char *str = itoa(0x1337BABE, itoa_buf, 16);
    if (str == 0) {
        puts("itoa failed\n");
    } else {
        puts(str);
        putnl();
    }
}
