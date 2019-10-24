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

