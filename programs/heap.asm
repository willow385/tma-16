; Program that uses main memory to store up to five kilobytes of data.
; I'm not sure how similar this is to the way stacks work in modern-day machines,
; but I think this is pretty neat nonetheless.

; IMPORTANT TODO: Version 1.8 of the assembler won't assemble this for some reason that I am too
; tired to fathom today. I need to fix this in version 1.9.

#define MEMORY_SIZE 1024

jmp @_main

#include "include_files/print.asm"

@_main:
    movl    rb      @MEM_PTR    ; pointer to where our program's memory is kept
    movl    ra      '\n'        ; to tell when we've gotten the end of our input
    movl    rd      MEMORY_SIZE ; so we know how much memory we have available
@_main_input_loop:
    get     rc                  ; get a single character
    jeq     rc  ra  @_main_output_loop ; is it a newl? then we're done getting input
    writr   rc  rb              ; write the entered character to main memory
    inc     rb                  ; move to the next byte
    jgr     rb  rd  @segfault   ; if too many chars have been written then segfault
    movr    rc  rb              ; save the address of the last char we wrote
    movl    rb      @MEM_PTR    ; set the pointer back to the first char
    jmp     @_main_input_loop   ; else get more chars

@_main_output_loop:
    jeq     rb  rc  @_main_exit ; exit if ptr to current char equal ptr to last char
    readr   ra  rb              ; fetch the char pointed to by rb
    out     ra                  ; output it
    inc     rb                  ; move the ptr to select the next char
    jmp     @_main_output_loop  ; print the next char

@_main_exit:
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
