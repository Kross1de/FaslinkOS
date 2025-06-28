#include "../include/stdio.h"
#include "../include/string.h"
extern void panic();

char *test_itoa_base_str(int base) {
    switch (base) {
        case 16: return "hex";
        case 10: return "decimal";
        case 8: return "octal";
        case 2: return "binary";
        default: return NULL;
    }
}

void test_itoa_print_base_str(int base, char *str) {
    char *base_str = test_itoa_base_str(base);
    if (base_str != NULL) {
        puts(base_str); 
    } else {
        puts("base ");
        str = itoa(base, str, 10);
        if (str == NULL) {
            puts("Error getting string from base");
        } else {
            puts(str);
        }
    }
}

void test_itoa_panic(int value, char *str, int base) {
    char *s;
    puts("itoa: Failed getting ");
    test_itoa_print_base_str(base, str);
    puts(" for number ");
    s = itoa(value, str, 10);
    if (str == NULL) {
        puts("Error getting string of number");
    } else {
        puts(s);
    }
    putnl();
    panic();
}

#define TEST_ITOA_OR_PANIC(value, itoa_buf, base) ({ \
        char *str = itoa(value, itoa_buf, base); \
        if (str == NULL) { \
            test_itoa_panic(value, itoa_buf, base); \
        }; \
        str; \
    })

void test_itoa_print_base(int base, char *itoa_buf) {
    puts("  Printing ");
    test_itoa_print_base_str(base, itoa_buf);
    puts(" from 0 to 40: ");
    for (int i = 0; i <= 40; i++) {
        puts(TEST_ITOA_OR_PANIC(i, itoa_buf, base)); puts(" ");
    }
    putnl();
}

void test_itoa_test_invalid_base(int base, char *itoa_buf) {
    char *str;
    test_itoa_print_base_str(base, itoa_buf);
    puts(" ");
    str = itoa(123456789, itoa_buf, base);
    if (str != NULL) {
        puts(" should have returned NULL, instead got:\n");
        puts(str); putnl();
        panic();
    }
    puts("OK ");
}

void test_itoa_test_invalid_bases(char *itoa_buf) {
    puts("\tTesting invalid bases: ");
    test_itoa_test_invalid_base(37, itoa_buf);
    test_itoa_test_invalid_base(1, itoa_buf);
    test_itoa_test_invalid_base(-123, itoa_buf);
    putnl();
}

void test_itoa() {
    char itoa_buf[33];
    puts("Testing char *itoa(int value, char *str, int base)\n");
    test_itoa_print_base(36, itoa_buf);
    test_itoa_print_base(24, itoa_buf);
    test_itoa_print_base(16, itoa_buf);
    test_itoa_print_base(10, itoa_buf);
    test_itoa_print_base(8, itoa_buf);
    test_itoa_print_base(2, itoa_buf);

    puts("\tPrinting negative base 10 numbers from -1 to -16: ");
    for (int i = -1; i > -16; i--) {
        puts(TEST_ITOA_OR_PANIC(i, itoa_buf, 10)); puts(" ");
    }
    putnl();

    puts("\tPrinting -123 in hex shouldn't be negative: ");
    puts(TEST_ITOA_OR_PANIC(-123, itoa_buf, 16)); putnl();

    puts("\tPrinting test values (0xCAFEBABE, 951842673, 0713275, 0b010011000111): ");
    puts(TEST_ITOA_OR_PANIC(0xCAFEBABE, itoa_buf, 16)); puts(" ");
    puts(TEST_ITOA_OR_PANIC(951842673, itoa_buf, 10)); puts(" ");
    puts(TEST_ITOA_OR_PANIC(0713275, itoa_buf, 8)); puts(" ");
    puts(TEST_ITOA_OR_PANIC(0b010011000111, itoa_buf, 2)); puts(" ");
    putnl();

    test_itoa_test_invalid_bases(itoa_buf);

    puts("Finished testing itoa\n");
}