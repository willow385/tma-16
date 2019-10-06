; Program to bitshift register a a bunch of times.
; Written to test the bitshift instruction.

#define LOOP_REPEAT_POINT 0x000B

movl    ra      0b0001000100010001 ; number that we'll be bitshifting
movl    rb      64                 ; number of times to loop
xor     rc      rc                 ; loop counter

; LOOP_REPEAT_POINT is here
bsl     ra
bsl     ra
bsl     ra
bsl     ra
inc     ra ; so that ra won't just zero out
inc     rc ; increment the loop counter
jgr     rb  rc  LOOP_REPEAT_POINT

halt
