; Program to bitshift register a a bunch of times.
; Written to test the bitshift instruction.

@_main:
    movl    ra      0b0001000100010001 ; number that we'll be bitshifting
    movl    rb      64                 ; number of times to loop
    xor     rc      rc                 ; loop counter

@loop_repeat_point:
    bsl     ra ; instruction to bitshift left
    bsl     ra
    bsl     ra
    bsl     ra
    inc     ra ; so that ra won't just zero out
    inc     rc ; increment the loop counter
    jgr     rb  rc  @loop_repeat_point

halt
