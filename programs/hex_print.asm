; This program prints an arbitrary 16-bit number to stdout in hexadecimal.
; Choose the number to print by editing the following macro:
#define NUMBER 0xBEEF

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

    ;-----------------------------------------------;
    ; Here I establish the calling convention for   ;
    ; functions in TMA-16 Assembly. You must push   ;
    ; the return address (where to go back to) onto ;
    ; the stack so that it's at the top, then jump  ;
    ; to the first op of the function. The function ;
    ; then should pop the return address into the   ;
    ; instruction pointer when it's done executing. ;
    ;-----------------------------------------------;

    movl    rd      @return_addr_0  ; so that we know where to go back to
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

; Call the function again
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

; Call the function again
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

; Call the function again
    movl    rd      @return_addr_3
    push    rd
    jmp     @print_digit

@return_addr_3:
    pop     ra

; print a newline
    movl    rd      '\n'
    out     rd

    halt

; Function for printing a single hex digit, which must be in ra
@print_digit:
    push    rb                   ; preserve rb's old value
    movl    rb      0x9          ; number to compare against ra
    jgr     ra  rb  @print_letter ; ra greater than 0x9? then print char in range A..F
    push    ra
    movl    rb      0x30         ; we can clobber this since it's already pushed
    add     ra      rb           ; ra now contains our ascii value
    out     ra                   ; print the ascii val of the number
    pop     ra
    pop     rb
    jmp     @print_digit_return
@print_letter:
    movl    rb      0x37 ; add this to number from 0xA to 0xF to get ascii value
    push    ra
    add     ra      rb
    out     ra
    pop     ra
    pop     rb
@print_digit_return:
    pop     ip         ; return address should have been pushed onto the stack for us
