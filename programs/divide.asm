jmp @_main

#define NUMERATOR 0x400
#define DENOMINATOR 0x40

#include "include_files/math.asm"

@_main:
    movl    ra      @_main_return
    push    ra
    movl    ra      NUMERATOR
    push    ra
    movl    ra      DENOMINATOR
    push    ra
    jmp             @divide
@_main_return:
    halt      
