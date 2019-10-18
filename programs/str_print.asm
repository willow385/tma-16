; program to print a hardcoded string to the TMA-16's stdout

#define STRING_START_PTR 0x001B ; the address of the string's first character
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

pb      'T'
pb      'h'
pb      'i'
pb      's'
pb      '\s'
pb      'p'
pb      'r'
pb      'o'
pb      'g'
pb      'r'
pb      'a'
pb      'm'
pb      '\s'
pb      'w'
pb      'a'
pb      's'
pb      '\s'
pb      'w'
pb      'r'
pb      'i'
pb      't'
pb      't'
pb      'e'
pb      'n'
pb      '\s'
pb      'i'
pb      'n'
pb      '\s'
pb      'T'
pb      'M'
pb      'A'
pb      '-'
pb      '1'
pb      '6'
pb      '\s'
pb      'A'
pb      's'
pb      's'
pb      'e'
pb      'm'
pb      'b'
pb      'l'
pb      'y'
pb      '\s'
pb      'b'
pb      'y'
pb      '\s'
pb      'D'
pb      'a'
pb      'n'
pb      't'
pb      'e'
pb      '\s'
pb      'F'
pb      'a'
pb      'l'
pb      'z'
pb      'o'
pb      'n'
pb      'e'
pb      '\n'
pb      0

