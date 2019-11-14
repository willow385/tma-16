; Subroutine to divide two numbers. To call this subroutine,
; first push the return address, then the number you want to
; divide, then the number by which you want to divide it.
; This program will leave the quotient in register A and the
; remainder in register B.
@divide:
    pop     rc                  ; denominator
    pop     rd                  ; numerator
    xor     ra  ra              ; quotient
    xor     rb  rb              ; remainder
    jeq     rc  ra  @_divide_by_zero
    jeq     rc  rd  @_divide_ez
    movr    rb  rd
@_divide_loop:
    jgr     rc  rb  @_divide_return
    jeq     rc  rb  @_divide_return
    inc     ra
    sub     rb  rc
    jmp             @_divide_loop
@_divide_return:
    pop     ip
@_divide_ez: ; If divisor equals dividend then our job is easy.
    movl    ra      1
    movl    rb      0
    pop     ip
@_divide_by_zero:
    movl    ra      'D'
    out     ra
    movl    ra      'I'
    out     ra
    movl    ra      'V'
    out     ra
    movl    ra      'I'
    out     ra
    movl    ra      'D'
    out     ra
    movl    ra      'E'
    out     ra
    movl    ra      '\s'
    out     ra
    movl    ra      'B'
    out     ra
    movl    ra      'Y'
    out     ra
    movl    ra      '\s'
    out     ra
    movl    ra      '0'
    out     ra
    movl    ra      '\n'
    out     ra
    halt
