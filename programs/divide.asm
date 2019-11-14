jmp @_main

#define NUMERATOR 37
#define DENOMINATOR 4

#include "include_files/print.asm"
#include "include_files/math.asm"

@_main:
    movl    ra      @_main_print_num
    push    ra
    movl    ra      NUMERATOR
    push    ra
    movl    ra      DENOMINATOR
    push    ra
    jmp             @divide
@_main_print_num:
    push    rb
    push    ra
    movl    ra      @_main_print_str0
    push    ra
    movl    ra      NUMERATOR
    push    ra
    jmp             @print_u16
@_main_print_str0:
    movl    ra      @_main_print_denom
    push    ra
    movl    ra      @str0
    push    ra
    jmp             @print_string
@_main_print_denom:
    movl    ra      @_main_print_str1
    push    ra
    movl    ra      DENOMINATOR
    push    ra
    jmp             @print_u16
@_main_print_str1:
    movl    ra      @_main_print_quotient
    push    ra
    movl    ra      @str1
    push    ra
    jmp             @print_string
@_main_print_quotient:
    pop     rb
    movl    ra      @_main_print_str2
    push    ra
    push    rb
    jmp             @print_u16
@_main_print_str2:
    movl    ra      @_main_print_remaind
    push    ra
    movl    ra      @str2
    push    ra
    jmp             @print_string    
@_main_print_remaind:
    pop     rb
    movl    ra      @_main_return
    push    ra
    push    rb
    jmp             @print_u16
@_main_return:
    movl    ra      '\n'
    out     ra
    halt      

@str0:
    pb      "\sd"
    pb      "iv"
    pb      "id"
    pb      "ed"
    pb      "\sb"
    pb      "y\s"
    pb      '\0'

@str1:
    pb      "\se"
    pb      "qu"
    pb      "al"
    pb      "s\s"
    pb      '\0'

@str2:
    pb      ",\s"
    pb      "re"
    pb      "ma"
    pb      "in"
    pb      "de"
    pb      "r\s"
    pb      '\0'
