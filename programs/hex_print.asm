; This program prints an arbitrary 16-bit number to stdout in hexadecimal.
; Choose the number to print by editing the following macro:
#define NUMBER 0x6AFF

; Macros for addresses
#define FIRST_LOOP_REPEAT   0x0019
#define SECOND_LOOP_REPEAT  0x003D
#define THIRD_LOOP_REPEAT   0x004A
#define FOURTH_LOOP_REPEAT  0x0067
#define FIFTH_LOOP_REPEAT   0x0074
#define SIXTH_LOOP_REPEAT   0x0091  
#define SEVENTH_LOOP_REPEAT 0x009E
#define SKIP_LOOP_SYMBOL    0x0034
#define RETURN_ADDRESS_0    0x002B
#define RETURN_ADDRESS_1    0x005C
#define RETURN_ADDRESS_2    0x0086
#define RETURN_ADDRESS_3    0x00B0
#define PRINT_DIGIT         0x00C5
#define PRINT_LETTER        0x00E2
#define PRINT_DIGIT_RET     0x00F1

; I must say, calculating all the addresses by hand is getting really tiring. I do
; like how it makes me feel like a Real Programmer, but I really need to implement
; address labels in the assembler.

; Print the prefix
movl    ra      '0'
out     ra
movl    ra      'x'
out     ra

; Now to use our NUMBER
movl    ra      NUMBER

; Push the number's original value on the stack
push    ra
; The number on the stack is still also in ra. Let's get its first digit by
; bitshifting right twelve times.
movl    rc      12
xor     rd      rd
; FIRST_LOOP_REPEAT:
bsr     ra
dec     rc
jgr     rc  rd  FIRST_LOOP_REPEAT ; back to the bsr operation

    ;-----------------------------------------------;
    ; Here I establish the calling convention for   ;
    ; functions in TMA-16 Assembly. You must push   ;
    ; the return address (where to go back to) onto ;
    ; the stack so that it's at the top, then jump  ;
    ; to the first op of the function. The function ;
    ; then should pop the return address into the   ;
    ; instruction pointer when it's done executing. ;
    ;-----------------------------------------------;

movl    rd      RETURN_ADDRESS_0  ; so that we know where to go back to
push    rd
jmp     PRINT_DIGIT

; RETURN_ADDRESS_0:
pop     ra

; Now we want to print the next digit of the number. This time we'll bitshift
; it left by 4 bits (to erase the leading digit), then right by twelve bits.

; I'm putting a symbol in the machine code for debugging purposes.
jmp     SKIP_LOOP_SYMBOL ; since we don't want to execute the symbol
pb      "lo"
pb      "op"

push    ra
movl    rc      4
xor     rd      rd
; SECOND_LOOP_REPEAT:
bsl     ra
dec     rc
jgr     rc  rd  SECOND_LOOP_REPEAT
movl    rc      12
; THIRD_LOOP_REPEAT:
bsr     ra
dec     rc
jgr     rc  rd  THIRD_LOOP_REPEAT
; Call the function again
movl    rd      RETURN_ADDRESS_1
push    rd
jmp     PRINT_DIGIT

; RETURN_ADDRESS_1:
pop     ra

; Now to print the third digit
push    ra
movl    rc      8
xor     rd      rd
; FOURTH_LOOP_REPEAT:
bsl     ra
dec     rc
jgr     rc  rd  FOURTH_LOOP_REPEAT
movl    rc      12
; FIFTH_LOOP_REPEAT:
bsr     ra
dec     rc
jgr     rc  rd  FIFTH_LOOP_REPEAT
; Call the function again
movl    rd      RETURN_ADDRESS_2
push    rd
jmp     PRINT_DIGIT

; RETURN_ADDRESS_2:
pop     ra

; And finally, the fourth and last digit of all
push    ra
movl    rc      12
xor     rd      rd
; SIXTH_LOOP_REPEAT:
bsl     ra
dec     rc
jgr     rc  rd  SIXTH_LOOP_REPEAT
movl    rc      12
; SEVENTH_LOOP_REPEAT:
bsr     ra
dec     rc
jgr     rc  rd  SEVENTH_LOOP_REPEAT
; Call the function again
movl    rd      RETURN_ADDRESS_3
push    rd
jmp     PRINT_DIGIT

; RETURN_ADDRESS_3:
pop     ra

; print a newline
movl    rd      '\n'
out     rd

halt

; symbol for debugging purposes
pb      "pr"
pb      "in"
pb      "t_"
pb      "di"
pb      "gi"
pb      "t\0"

; Function for printing a single hex digit, which must be in ra
; PRINT_DIGIT:
push    rb                   ; preserve rb's old value
movl    rb      0x9          ; number to compare against ra
jgr     ra  rb  PRINT_LETTER ; ra greater than 0x9? then print char in range A..F
push    ra
movl    rb      0x30         ; we can clobber this since it's already pushed
add     ra      rb           ; ra now contains our ascii value
out     ra                   ; print the ascii val of the number
pop     ra
pop     rb
jmp     PRINT_DIGIT_RET
; PRINT_LETTER:
movl    rb      0x37 ; add this to number from 0xA to 0xF to get ascii value
push    ra
add     ra      rb
out     ra
pop     ra
pop     rb
; PRINT_DIGIT_RET:
pop     ip         ; return address should have been pushed onto the stack for us
