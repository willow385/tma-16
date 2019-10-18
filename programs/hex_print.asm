; NOTE! As of 18 October this program is not finished - see line 31 for details

; This program prints an arbitrary 16-bit number to stdout in hexadecimal.
; Choose the number to print by editing the following macro:
#define NUMBER 0x6F3D

; Macros for addresses
#define FIRST_LOOP_REPEAT 0x0019
#define PRINT_LETTER 0xBEEF
#define PRINT_DIGIT_RET 0xB00B

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
; bitshifting right twelve times
movl    rc      12
xor     rd      rd
bsr     ra
dec     rc
jgr     rc  rd  FIRST_LOOP_REPEAT

; TODO!!! Finish this! Call PRINT_DIGIT on each loop!

halt

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
push    rb
movl    rb      0x37 ; add this to number from 0xA to 0xF to get ascii value
push    ra
add     ra      rb
out     ra
pop     ra
pop     rb
; PRINT_DIGIT_RET:
pop     ip         ; return address should have been pushed onto the stack for us
