; Subroutine to check if two null-terminated strings are the same.
; Leaves the result in register A: 1 if they're the same, 0 otherwise.
; Push the return address, then the pointer to the first string, then
; the pointer to the second string, before jumping here.
@strcmp:
    pop     rb              ; string 0
    pop     rc              ; string 1
@_strcmp_L0:
    readr   rd  rc          ; fetch a char from string 1
    readr   ra  rb          ; fetch a char from string 0
    jeq     ra  rd  @_strcmp_L0_nextchar
    jmp             @_strcmp_ret0
@_strcmp_L0_nextchar:
    ; if we've reached null chars for both strings, then we're done.
    push    rc              ; save this value - it's important
    xor     rc  rc          ; zero out register C for comparison
    jeq     ra  rc  @_strcmp_ret1
    pop     rc
    inc     rc
    inc     rb
    jmp             @_strcmp_L0
@_strcmp_ret0:
    ; we should jump here if the strings are not the same
    xor     ra  ra
    pop     ip
@_strcmp_ret1:
    ; pop the value we pushed from rc
    pop     rc

    ; we should jump here if the strings are the same
    movl    ra      1
    pop     ip  
