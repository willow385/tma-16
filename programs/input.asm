; Program to get input from the user and print it back out.

#define STR_0_PTR  0x0044
#define STR_0_LOOP 0x0007
#define GET_INPUT  0x0016
#define INPUT_LOOP 0x001C
#define OUTPUT     0x0030
#define END        0x003C

xor     rd      rd          ; Zero out rd for comparisons
movl    ra      STR_0_PTR   ; Put a pointer to our string's first char in ra
; STR_0_LOOP:
readr   rb      ra          ; Fetch the caracter & stash in rb
jeq     rb  rd  GET_INPUT   ; character is null? then we're done printing
out     rb
inc     ra                  ; point to next character
jmp     STR_0_LOOP          ; print the next character


; GET_INPUT:
push    rd                  ; null char at the end
movl    rb      '\n'        ; to check when the user is done typing
; INPUT_LOOP:
get     ra                  ; store whatever the user types next in ra
out     ra                  ; let the user see what they just typed
jeq     ra  rb  OUTPUT      ; user pressed enter? then we're done here
push    ra                  ; else, put the string on the stack
jmp     INPUT_LOOP          ; get the next character

; I am fully aware how easy it would be for the user to cause a stack overflow here.
; This program is meant to test the get operation, not to be robust.


movl    ra      '\n'
out     ra
; OUTPUT:
pop     ra                  ; get a char off the stack
jeq     ra  rd  END         ; is it a null char? then we're done here
out     ra                  ; else, print it
jmp     OUTPUT              ; print the next one

; END:
movl    ra      '\n'
out     ra
out     ra
halt

; STR_0_PTR:
pb      "Ty"
pb      "pe"
pb      "\sl"
pb      "es"
pb      "s\s"
pb      "th"
pb      "an"
pb      "\s1"
pb      "7\s"
pb      "ch"
pb      "ar"
pb      "s\s"
pb      "to"
pb      "\ss"
pb      "ee"
pb      "\st"
pb      "he"
pb      "m\s"
pb      "re"
pb      "ve"
pb      "rs"
pb      "ed"
pb      ":\s"
pb      0
