; A program written in TMA-16 assembly that multiplies two
; numbers defined by macro constants. I wrote it to multiply
; 3 by 7 but you can change that by editing the macros below.
#define MULT_OPERAND_0      3
#define MULT_OPERAND_1      7
#define EXPECTED_RESULT    21

; don't change these two
#define ADD_LOOP_START 0x000F ; address of the `add' operation
#define STRING_PRINT   0x0023 ; address where we start printing to stdout

movl    ra    MULT_OPERAND_0  ; first operand
movl    rb    MULT_OPERAND_1  ; second operand
movr    rc    ra              ; copy the original value of the first operand
movl    rd    1               ; we'll compare against this to see if we're done

add     ra    rc              ; we'll repeat this to perform the multiplication
dec     rb                    ; decrement the counter
jgr     rb rd ADD_LOOP_START  ; if 1 > rb then goto add operation


movl    rd    EXPECTED_RESULT ; now to compare and see if we got the right answer
jeq     rd ra STRING_PRINT    ; ra == EXPECTED_RESULT ? goto STRING_PRINT : halt

halt                       ; if ra != EXPECTED_RESULT then we exit here

; if we got here, then it must mean that ra contains the EXPECTED_RESULT, and that
; our program therefore successfully multiplied MULT_OPERAND_0 by MULT_OPERAND_1
movl    rd   'D'
out     rd
movl    rd   'O'
out     rd
movl    rd   'N'
out     rd
movl    rd   'E'
out     rd
movl    rd   '\n'
out     rd
halt
