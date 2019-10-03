; program to divide two numbers

#define NUMERATOR       12
#define DENOMINATOR     0

; memory addresses to which we jump
#define DIVIDE_BY_ZERO        0x004A
#define DENOM_BIGGER_THAN_NUM 0x00A3
#define LOOP_REPEAT           0x0019
#define DONE                  0x002B

movl    ra      NUMERATOR      ; value we compare against
movl    rb      DENOMINATOR    ; value we add each loop
movl    rc      0              ; we'll use rc to count how many times we've looped
xor     rd      rd             ; we'll use this as an accumulator

jeq     rb  rd  DIVIDE_BY_ZERO
jgr     rb  ra  DENOM_BIGGER_THAN_NUM

; The division algorithm here works by counting the number of times you
; have to add the denominator to itself to equal the numerator. Hence
; the denominator can't be higher than the numerator.
; LOOP_REPEAT:
jeq     rd  ra  DONE           ; if we've reached the numerator, we're done
inc     rc                     ; add til we reach the number of times num goes into denom
add     rd      rb             ; add to get up to the numerator     
jgr     rd  ra  DONE           ; if we've gone past the numeraator, it's not evenly divisible
jmp     LOOP_REPEAT


; DONE:
push    rc
movl    rd      68
out     rd
movl    rd      79
out     rd
movl    rd      78
out     rd
movl    rd      69
out     rd
halt ; the result should now be on the top of the stack

; DIVIDE_BY_ZERO:
movl    rd      68
out     rd
movl    rd      73
out     rd
movl    rd      86
out     rd
movl    rd      73
out     rd
movl    rd      68
out     rd
movl    rd      69
out     rd
movl    rd      32
out     rd
movl    rd      66
out     rd
movl    rd      89
out     rd
movl    rd      32
out     rd
movl    rd      90
out     rd
movl    rd      69
out     rd
movl    rd      82
out     rd
movl    rd      79
out     rd
halt

; DENOM_BIGGER_THAN_NUM:
movl    rd      68
out     rd
movl    rd      69
out     rd
movl    rd      78
out     rd
movl    rd      79
out     rd
movl    rd      77
out     rd
movl    rd      32
out     rd
movl    rd      84
out     rd
movl    rd      79
out     rd
movl    rd      79
out     rd
movl    rd      32
out     rd
movl    rd      66
out     rd
movl    rd      73
out     rd
movl    rd      71
out     rd
halt
