movl    ra      15
movl    rb      0xEEEE ; E
push    rb
dec     ra
jeq     ra rc   0x0014
jmp     0x0008

pop     rb
inc     ra
movl    rd      15
jeq     ra rd   0x0008
jmp     0x0014

; no halt needed; this program runs indefinitely
