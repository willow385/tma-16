; Program that never stops running

#define STACK_SIZE          16  ; maximum number of bytes we want to push

; Stack pushing loop
movl    ra      STACK_SIZE      ; counter for how many times to push onto stack
movl    rb      0xCCCC          ; value to push onto the stack
movr    rd      ra              ; keep track of the stack size - don't clobber rd

@push_loop:
    push    rb                  ; push it
    dec     ra                  ; decrement the counter
    jeq     ra rc   @pop_loop   ; if counter == 0, goto pop operation below
    jmp     @push_loop          ; else, go back up to push operation

; Stack popping loop
@pop_loop:
    pop     rb                  ; take a byte off
    inc     ra                  ; increment counter
    jeq     ra rd   @push_loop  ; if counter == 16, goto push operation above
    jmp     @pop_loop           ; else, go back to pop operation

; No halt needed; this program runs indefinitely.
; Enjoy watching it fill and empty your stack over
; and over again until you pkill or ^C the vm.
