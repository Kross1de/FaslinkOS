#include "../include/stdio.h"
extern void panic();

void test_printf_panic(char *format, ...) {
    puts("printf: Failed printing format:\n\t");
    puts(format);
    putnl();
    // TODO: get vargs
    panic();
}

// FIXME: Use ... and __VA_ARGS__
#define TEST_PRINTF_OR_PANIC(format, arg) ({ \
        int i = printf(format, arg); \
        if (i < 0) { \
            test_printf_panic(format, arg); \
        }; \
        i; \
    })
    
#define TEST_PRINTF_OR_PANIC_NO_ARGS(format) ({ \
        int i = printf(format); \
        if (i < 0) { \
            test_printf_panic(format); \
        }; \
        i; \
    })

void test_printf() {
    puts("Testing int printf(char *format, ...)\n");
    // FIXME: use one macro onwe get vargs working
    TEST_PRINTF_OR_PANIC_NO_ARGS("Testing printf with no format flags\n");
    TEST_PRINTF_OR_PANIC_NO_ARGS("Testing printf with escaped percent: %%\n");
    TEST_PRINTF_OR_PANIC("Testing printf with the string OK: %s\n", "OK");
    TEST_PRINTF_OR_PANIC("Testing printf with the hex number 0xCAFE: %x\n", 0xCAFE);
    TEST_PRINTF_OR_PANIC("Testing printf with the octal number 0753: %o\n", 0753);
    TEST_PRINTF_OR_PANIC("Testing printf with the signed decimal number -127: %d\n", -127);
    TEST_PRINTF_OR_PANIC("Testing printf with the signed decimal number 593: %d\n", 593);
    TEST_PRINTF_OR_PANIC("Testing printf with the unsigned decimal number -127: %u\n", -127);
    TEST_PRINTF_OR_PANIC("Testing printf with the unsigned decimal number 593: %u\n", 593);
// TODO: test with edge cases
    puts("Finished testing printf\n");
}