jmp @_main

#define NUMERATOR 37
#define DENOMINATOR 4

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
