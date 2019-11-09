; Subroutine to print a string.
; To call this subroutine, push the return address and push a pointer to a null-
; terminated string, then jmp to @print_string. This will clobber ra, rb, and rd.
@print_string:
    pop     ra                  ; ra should now contain the address of the string
    xor     rd      rd          ; for zero comparison
@_print_string_get_next_char:
    readr   rb      ra          ; get the char pointed to
    ; char is null? then we're done
    jeq     rb  rd  @_print_string_return
    out     rb                  ; else, print the char
    inc     ra                  ; move pointer to next char
    jmp     @_print_string_get_next_char
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
    jmp     @_print_digit_return
@_print_digit_A_F:
    movl    rb      0x37 ; add this to number from 0xA to 0xF to get ascii value
    push    ra
    add     ra      rb
    out     ra
    pop     ra           ; unclobber registers
    pop     rb
@_print_digit_return:
    pop     ip
