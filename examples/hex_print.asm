; This program prints an arbitrary 16-bit number to stdout in hexadecimal.
; Choose the number to print by editing the following macro:
#define NUMBER 0xBEEF

jmp @_main

#include "include_files/print.asm"

@_main:
    movl    ra      @_main_return
    push    ra
    movl    ra      NUMBER
    push    ra
    jmp             @print_u16

@_main_return:
    movl    ra      '\n'
    out     ra
    halt
