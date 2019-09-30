; program to print a hardcoded string to the TMA-16's stdout

#define STRING_START_PTR 0x001F ; the address of the string's first character
#define HALT_OP_ADDRESS  0x0019 ; the program's exit point
#define READR_OP_ADDRESS 0x0008 ; an address we'll need to jump back to repeatedly

movl    rd      0                ; for comparing to see if we've hit a null char yet
movl    rb      STRING_START_PTR ; address where the string starts
readr   ra      rb               ; find the address pointed to by rb and store its value in ra
jeq     ra rd   HALT_OP_ADDRESS  ; if it's '\0', then go to the `halt` instruction
out     ra                       ; otherwise, print to stdout
inc     rb                       ; inc string pointer by 2 since all numeric literals are 2 bytes wide
inc     rb
jmp     READR_OP_ADDRESS         ; go back to the "readr" instruction

halt


; Now you can put as many letters here as the TMA-16 can address!
; If you really wanted you could put almost 32KB of text here.

; To be fair I cheated here. I didn't type these all out; I wrote
; a 3-line Python script to do it for me. This is why I really should
; build macros and syntactic sugar into the assembler.

pb      84
pb      104
pb      105
pb      115
pb      32
pb      112
pb      114
pb      111
pb      103
pb      114
pb      97
pb      109
pb      32
pb      119
pb      97
pb      115
pb      32
pb      119
pb      114
pb      105
pb      116
pb      116
pb      101
pb      110
pb      32
pb      105
pb      110
pb      32
pb      84
pb      77
pb      65
pb      45
pb      49
pb      54
pb      32
pb      65
pb      115
pb      115
pb      101
pb      109
pb      98
pb      108
pb      121
pb      32
pb      98
pb      121
pb      32
pb      68
pb      97
pb      110
pb      116
pb      101
pb      32
pb      70
pb      97
pb      108
pb      122
pb      111
pb      110
pb      101
pb      0

