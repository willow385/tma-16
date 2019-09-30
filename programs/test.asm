; test.asm - a program to test the TMA-16 
; and make sure it's running more or less
; in accordance with the specification

; first, an unconditional jump instruction to take us past the values
; "HELLO" we're putting down there with ``pb'' directives
jmp     0x000D

; Now let's put the word "HELLO" in the executable using pb ("put byte")
; Remember when aligning addresses that sizeof(int) on the TMA-16 is 2 bytes.
pb      72
pb      69      ; nice
pb      76
pb      76
pb      79

; move literal (movl) - move a literal integer value into a register
movl    ra      0b11010 ; this `movl' op will be the 0xDth byte of the executable
movl    rb      0b10110

; AND operation
and     ra      rb      ; should store binary 10010 (==0x12) in ra

; push ra onto the stack
push    ra              ; the stack should now have the number 0x12 at the bottom of it

; now for another fun operation: the OR operation
movl    ra      0b11000
movl    rb      0b00011
or      ra      rb      ; should store binary 11011 (==0x1B) in ra

push    ra              ; now the stack should have the number 0x1B on it

; and now for the XOR operation
movl    ra      0b10011
movl    rb      0b11001
xor     ra      rb      ; should store binary 01010 (==0x0A) in ra
push    ra              ; ...which, surprise surprise, should now be on the stack

; and the beloved logical NOT
not     ra              ; now ra should contain binary 1111111111101100 (==0xFFF5)
push    ra

; By now, the stack should have these
; hex values from bottom to top: 0012 001B 000A FFF5
; If it doesn't, then there's an implementation bug in your TMA-16.

; Now let's try using the ``read'' operation to get the ``HELLO''
; we put up there using the ``pb'' assembler directive.
; This should result in ``HELLO'' being printed to stdout.
read    ra      0x0004
out     ra
read    ra      0x0006
out     ra
read    ra      0x0008
out     ra
read    ra      0x000A
out     ra
read    ra      0x000C
out     ra

; Now let's check to see if the stack will tell it's being overflowed.
movl    rc      13     ; loop counter (hardcoded to be 1 more than the number of null bytes left on the stack)
movl    rd      0      ; to compare the loop counter against
push    ra             ; if we do this enough times we should overflow the stack
dec     rc             ; decrement the counter
jgr     rc rd   0x005E ; the push instruction right above here

ovrf    rb      ; copy the stack flag (which should be 1 since we overflowed) into register b

; now we're going print a newline
movl    rd      10
out     rd

; time to reset the overflow flag
clrovr

; and then pop the values of the stack out, printing them one by one
xor     ra      ra ; should clear ra to 0
movl    rc      16
movl    rd      0
pop     ra
out     ra
dec     rc
jgr     rc rd   0x007B

; this should result in the string "OOOOOOOOOOOO" printed to stdout

halt
