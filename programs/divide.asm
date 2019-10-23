; This program divides two unsigned integers and leaves the result on the stack.

; The constants NUMERATOR and DENOMINATOR are set to 12 and 4 respectively
; but you can change them to whatever you like. For best results, ensure
; that the denominator is less than or equal to the numerator.
#define NUMERATOR       12
#define DENOMINATOR     4


movl    ra      NUMERATOR      ; value we compare against
movl    rb      DENOMINATOR    ; value we add each loop
movl    rc      0              ; we'll use rc to count how many times we've looped
xor     rd      rd             ; we'll use this as an accumulator

jeq     rb  rd  @divide_by_zero
jgr     rb  ra  @denom_bigger_than_num

; The division algorithm here works by counting the number of times you
; have to add the denominator to itself to equal the numerator. Hence
; the denominator can't be higher than the numerator.
@loop_repeat:
    jeq     rd  ra  @done          ; if we've reached the numerator, we're done
    inc     rc                     ; add til we reach the number of times num goes into denom
    add     rd      rb             ; add to get up to the numerator     
    jgr     rd  ra  @done          ; if we've gone past the numerator, it's not evenly divisible
    jmp     @loop_repeat


@done:
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

@divide_by_zero:
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

@denom_bigger_than_num:
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
