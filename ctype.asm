format elf
section '.text' executable
use32
public isdigit

isdigit:
        enter 0, 0
        cmp [ebp + 8], '0'
        jl .fail
        cmp [ebp + 8], '9'
        jg .fail
        mov eax, 1
        jmp .return
.fail:
        mov eax, 0
.return:
        leave
        ret