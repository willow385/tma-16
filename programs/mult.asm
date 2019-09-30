; A program written in TMA-16 assembly that multiplies two
; numbers: 3 and 7, resulting in 21.

movl    ra   3             ; first operand
movl    rb   7             ; second operand
movr    rc   ra            ; copy the original value of the first operand
movl    rd   1             ; we'll compare against this to see if we're done

add     ra   rc            ; address of this op is at 0x000F
dec     rb                 ; decrement the counter
jgr     rb   rd     0x000F ; if 1 > rb then goto add operation


movl    rd   21            ; now to compare and see if we got the right answer
jeq     rd   ra     0x0027 ; ra == 21 ? goto 0x0027 : halt

halt                       ; if ra != 21 then we exit here

movl    rd   51            ; ascii '3'
out     rd
movl    rd   32            ; ascii space
out     rd
movl    rd   42            ; ascii asterisk
out     rd
movl    rd   32
out     rd
movl    rd   55            ; ascii '7'
out     rd
movl    rd   32
out     rd
movl    rd   61            ; ascii '='
out     rd
movl    rd   32
out     rd
movl    rd   50            ; ascii '2'
out     rd
movl    rd   49            ; ascii '1'
out     rd
movl    rd   10            ; newline
out     rd
halt
