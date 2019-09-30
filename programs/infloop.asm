movl    ra      15     ; counter for how many times to push onto stack
movl    rb      0xEEEE ; value to push onto the stack
push    rb             ; push it
dec     ra             ; decrement the counter
jeq     ra rc   0x0014 ; if counter == 0, goto pop operation below
jmp     0x0008         ; else, go back up to push operation

pop     rb             ; take a byte off
inc     ra             ; increment counter
movl    rd      15     ; prepare this value for comparison
jeq     ra rd   0x0008 ; if counter == 15, goto push operation above
jmp     0x0014         ; else, go back to pop operation

; No halt needed; this program runs indefinitely.
; Enjoy watching it fill and empty your stack over
; and over again until you pkill or ^C the vm.
