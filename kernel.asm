format elf
section '.text' executable
public kmain
extrn busy_loop

include 'include/vga.inc'
include 'include/string.inc'

extrn run_tests

use32

kmain:
    enter 0, 0
    call run_tests
.return:
	leave
	ret
