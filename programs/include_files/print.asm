; Subroutine to print a string.
; To call this subroutine, push the return address and push a pointer to a null-
; terminated string, then jmp to @print_string. This will clobber ra, rb, and rd.
@print_string:
    pop     ra                  ; ra should now contain the address of the string
    xor     rd      rd          ; for zero comparison
@_print_string_next_char:
    readr   rb      ra          ; get the char pointed to
    ; char is null? then we're done
    jeq     rb  rd  @_print_string_return
    out     rb                  ; else, print the char
    inc     ra                  ; move pointer to next char
    jmp             @_print_string_next_char
@_print_string_return:
    pop     ip


; Subroutine to print a single hexadecimal digit. To call this subroutine,
; push the return address, put a 4-bit number in register A, and jump to
; it. This will not clobber anything.
@print_digit:
    push    rb                   ; preserve rb's old value
    movl    rb      0x9          ; number to compare against ra
    jgr     ra  rb  @_print_digit_A_F ; ra > 0x9 ? then char in range A..F
    push    ra
    movl    rb      0x30         ; we can clobber this since it's already pushed
    add     ra      rb           ; ra now contains our ascii value
    out     ra                   ; print the ascii val of the number
    pop     ra                   ; unclobber registers
    pop     rb
    jmp             @_print_digit_return
@_print_digit_A_F:
    movl    rb      0x37 ; add this to number from 0xA to 0xF to get ascii value
    push    ra
    add     ra      rb
    out     ra
    pop     ra           ; unclobber registers
    pop     rb
@_print_digit_return:
    pop     ip


; Subroutine to print a 16-bit unsigned integer in hexadecimal.
; To call this subroutine, push the return address, then the number.
; This will clobber everything.
@print_u16:
    pop     ra
    ; here we print the hexadecimal prefix, "0x"
    movl    rc      '0'
    movl    rd      'x'
    out     rc
    out     rd
    ; get the leading digit
    movl    rc      12
    xor     rd      rd
    push    ra
@_print_u16_loop0:
    bsr     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop0
    movl    rd      @_print_u16_ret0  ; return address for print_digit
    push    rd
    jmp             @print_digit
@_print_u16_ret0:
    pop     ra
    push    ra
    movl    rc      4
    xor     rd      rd
@_print_u16_loop1:
    bsl     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop1
    movl    rc      12
@_print_u16_loop2:
    bsr     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop2
    movl    rd      @_print_u16_ret1
    push    rd
    jmp             @print_digit
@_print_u16_ret1:
    pop     ra
    push    ra
    movl    rc      8
    xor     rd      rd
@_print_u16_loop3:
    bsl     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop3
    movl    rc      12
@_print_u16_loop4:
    bsr     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop4
    movl    rd      @_print_u16_ret2
    push    rd
    jmp     @print_digit
@_print_u16_ret2:
    pop     ra
    movl    rc      12
    xor     rd      rd
@_print_u16_loop5:
    bsl     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop5
    movl    rc      12
@_print_u16_loop6:
    bsr     ra
    dec     rc
    jgr     rc  rd  @_print_u16_loop6
    movl    rd      @_print_u16_ret3
    push    rd
    jmp             @print_digit
@_print_u16_ret3:
    pop     ip
