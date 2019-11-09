; This program prints an arbitrary 16-bit number to stdout in hexadecimal.
; Choose the number to print by editing the following macro:
#define NUMBER 0xBEEF

jmp @_main

#include "include_files/print.asm"

@_main:
; Print the prefix
    movl    ra      '0'
    out     ra
    movl    ra      'x'
    out     ra

; Now to use our NUMBER
    movl    ra      NUMBER

; Push the number's original value on the stack
    push    ra
; The number on the stack is still also in ra. Let's get its first digit by
; bitshifting right twelve times.
    movl    rc      12
    xor     rd      rd

@loop0:
    bsr     ra
    dec     rc
    jgr     rc  rd  @loop0
    movl    rd      @return_addr_0  ; return address for print_digit
    push    rd
    jmp     @print_digit

@return_addr_0:
    pop     ra
; Now we want to print the next digit of the number. This time we'll bitshift
; it left by 4 bits (to erase the leading digit), then right by twelve bits.
    push    ra
    movl    rc      4
    xor     rd      rd

@loop1:
    bsl     ra
    dec     rc
    jgr     rc  rd  @loop1
    movl    rc      12

@loop2:
    bsr     ra
    dec     rc
    jgr     rc  rd  @loop2

; Call the subroutine again
    movl    rd      @return_addr_1
    push    rd
    jmp     @print_digit

@return_addr_1:
    pop     ra

; Now to print the third digit
    push    ra
    movl    rc      8
    xor     rd      rd

@loop3:
    bsl     ra
    dec     rc
    jgr     rc  rd  @loop3
    movl    rc      12

@loop4:
    bsr     ra
    dec     rc
    jgr     rc  rd  @loop4

; Call the subroutine again
    movl    rd      @return_addr_2
    push    rd
    jmp     @print_digit

@return_addr_2:
    pop     ra

; And finally, the fourth and last digit of all
    push    ra
    movl    rc      12
    xor     rd      rd

@loop5:
    bsl     ra
    dec     rc
    jgr     rc  rd  @loop5
    movl    rc      12

@loop6:
    bsr     ra
    dec     rc
    jgr     rc  rd  @loop6

; Call the subroutine again
    movl    rd      @return_addr_3
    push    rd
    jmp     @print_digit

@return_addr_3:
    pop     ra

; print a newline
    movl    rd      '\n'
    out     rd

    halt ; exit point for _main
