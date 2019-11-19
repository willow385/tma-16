movl    ra      MY_FANTASTIC_MACRO ; A wild MACRO appeared!
movr    rb      ra
out     rb

; Now we're going to use that fancy macro feature
; that I just wrote into the assembler.
; Let's tell the assembler to expand "MY_FANTASTIC_MACRO"
; into the ascii code for 'E'.
#define MY_FANTASTIC_MACRO 69

halt
