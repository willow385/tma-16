; Hello world in TMA-16 Assembly (written for version 1.8 or later of the assembler)

jmp @_main

#include "include_files/print.asm"

@_main:
    movl    ra      @return_address     ; where to return from @print_string
    push    ra
    movl    ra      @string_ptr         ; where the string is
    push    ra
    jmp     @print_string

@return_address:
    halt

@string_ptr:
    pb      "He"
    pb      "ll"
    pb      "o,"
    pb      "\sw"
    pb      "or"
    pb      "ld"
    pb      "!\n"
    pb      0
