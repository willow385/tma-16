; Program to get input from the user and print it back out.

    xor     rd      rd          ; Zero out rd for comparisons
    movl    ra      @prompt     ; Put a pointer to our string's first char in ra

@print_prompt_char:
    readr   rb      ra          ; Fetch the character & stash in rb
    jeq     rb  rd  @get_input  ; character is null? then we're done printing
    out     rb
    inc     ra                  ; point to next character
    jmp     @print_prompt_char  ; print the next character


@get_input:
    push    rd                  ; null char at the end
    movl    rb      '\n'        ; to check when the user is done typing
@input_loop:
    get     ra              ; store whatever the user types next in ra
    out     ra              ; let the user see what they just typed
    jeq     ra  rb  @output ; user pressed enter? then we're done here
    push    ra              ; else, put the string on the stack
    jmp     @input_loop     ; get the next character

; I am fully aware how easy it would be for the user to cause a stack overflow here.
; This program is meant to test the get operation, not to be robust.


@output:
    pop     ra                  ; get a char off the stack
    jeq     ra  rd  @end        ; is it a null char? then we're done here
    out     ra                  ; else, print it
    jmp     @output             ; print the next one

@end:
    movl    ra      '\n'
    out     ra
    out     ra
    halt

@prompt:
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
