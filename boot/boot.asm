format elf
section '.boot' executable

include 'boot16.inc'
section '.boot32' executable
include 'boot32.inc'
section '.bss' executable
include 'stack.inc'