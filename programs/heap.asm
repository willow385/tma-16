; Program that uses main memory to store up to ten kilobytes of data.
; I'm not sure how similar this is to the way stacks work in modern-day machines,
; but I think this is pretty neat nonetheless. I'm referring to it as a "heap"
; until someone tells me why that's wrong.


#define MEMORY_SIZE 10240

jmp @_main

#include "include_files/print.asm"

@_main:
    movl    rb      @MEM_PTR    ; pointer to where our program's memory is kept
    movl    ra      '\n'        ; to tell when we've gotten the end of our input
    movl    rd      MEMORY_SIZE ; so we know how much memory we have available
@_main_input_loop:
    get     rc                  ; get a single character
    jeq     rc  ra  @_main_output ; is it a newl? then we're done getting input
    writr   rc  rb              ; write the entered character to main memory
    inc     rb                  ; move to the next byte
    jgr     rb  rd  @segfault   ; if too many chars have been written then segfault
    movr    rc  rb              ; save the address of the last char we wrote
    jmp     @_main_input_loop   ; else get more chars

@_main_output:
    movl    rb  @MEM_PTR
    xor     rc  rc
@_main_output_loop:
    jeq     ra  rc  @_main_exit ; exit if ptr to current char equal ptr to last char
    readr   ra  rb              ; fetch the char pointed to by rb
    out     ra                  ; output it
    inc     rb                  ; move the ptr to select the next char
    jmp     @_main_output_loop  ; print the next char

@_main_exit:
    movl    ra  '\n'
    out     ra
    halt

@segfault:
    movl    ra      @_main_exit ; return address for print_string
    push    ra
    movl    ra      @segfault_str_ptr ; pointer to the string to print
    push    ra
    jmp     @print_string
    
@segfault_str_ptr:
    pb      "Se"
    pb      "gm"
    pb      "en"
    pb      "ta"
    pb      "ti"
    pb      "on"
    pb      "\sf"
    pb      "au"
    pb      "lt"
    pb      "\n\0"

@MEM_PTR:
    alloc   MEMORY_SIZE
