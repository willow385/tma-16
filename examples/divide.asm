; This program demonstrates the usage of the @divide subroutine
; in the math library for TMA-16 Assembly.

jmp @_main

; For demonstration purposes we'll be dividing 0x1776 by 0x4, but
; these could be any unsigned 16-bit integers.
#define NUMERATOR 0x1776
#define DENOMINATOR 0x4

#include "include_files/print.asm"
#include "include_files/math.asm"

@_main:
    ; Here we set up the arguments to @divide so we can jump to it.
    ; As with all TMA-16 Assembly subroutines, the first thing we
    ; push is the address to jump back to when the subroutine returns.
    movl    ra      @_main_print_num     ; return address for @divide
    push    ra
    movl    ra      NUMERATOR            ; number to divide
    push    ra
    movl    ra      DENOMINATOR          ; number by which to divide
    push    ra
    jmp             @divide

; The division will have already been performed by now. The rest of the program
; is just neatly outputting the results in a clear and readable form.
@_main_print_num:
    push    rb      ; save the values, which are in registers A and B
    push    ra
    movl    ra      @_main_print_str0    ; return address
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
