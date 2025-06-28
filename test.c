#include "include/stdio.h"

extern void test_itoa();

void run_tests() {
    puts("This was printed from test.c in run_tests()\n");
    test_itoa();
}
