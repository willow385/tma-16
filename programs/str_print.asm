; program to print a hardcoded string to the TMA-16's stdout

jmp @_main

#include "include_files/print.asm"

@_main:
    movl    ra      @return_address
    push    ra
    movl    ra      @string_ptr
    push    ra
    jmp     @print_string

@return_address:
    halt


; Now you can put as many letters here as the TMA-16 can address!
; If you really wanted you could put almost 32KB of text here.
@string_ptr:
    pb      "Th"
    pb      "is"
    pb      "\sp"
    pb      "ro"
    pb      "gr"
    pb      "am"
    pb      "\sw"
    pb      "as"
    pb      "\sw"
    pb      "ri"
    pb      "tt"
    pb      "en"
    pb      "\si"
    pb      "n\s"
    pb      "TM"
    pb      "A-"
    pb      "16"
    pb      "\sA"
    pb      "ss"
    pb      "em"
    pb      "bl"
    pb      "y\s"
    pb      "by"
    pb      "\sD"
    pb      "an"
    pb      "te"
    pb      "\sF"
    pb      "al"
    pb      "zo"
    pb      "ne"
    pb      "\n\0"

