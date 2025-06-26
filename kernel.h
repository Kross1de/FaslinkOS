#pragma once

extern void vga_init();
extern void vga_putchar(char);
extern void vga_puts(char *);
extern void vga_putchar_at(char c, int fg_colour, int bg_color, int x, int y);
