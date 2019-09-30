; Stack pushing loop
movl    ra      STACK_SIZE      ; counter for how many times to push onto stack
movl    rb      0xEEEE          ; value to push onto the stack
push    rb                      ; push it
dec     ra                      ; decrement the counter
jeq     ra rc   POP_OP_ADDRESS  ; if counter == 0, goto pop operation below
jmp     PUSH_OP_ADDRESS         ; else, go back up to push operation

; Stack popping loop
pop     rb                      ; take a byte off
inc     ra                      ; increment counter
movl    rd      STACK_SIZE      ; prepare this value for comparison
jeq     ra rd   PUSH_OP_ADDRESS ; if counter == 15, goto push operation above
jmp     POP_OP_ADDRESS          ; else, go back to pop operation

; No halt needed; this program runs indefinitely.
; Enjoy watching it fill and empty your stack over
; and over again until you pkill or ^C the vm.

#define PUSH_OP_ADDRESS 0x0008 ; address of the push operation
#define POP_OP_ADDRESS  0x0014 ; address of the pop operation
#define STACK_SIZE          15 ; maximum number of bytes we want to push
