; Program that reads in up to five kilobytes of characters and
; prints them back out backwards, written to test usage of
; subroutines in include_files/memstack.asm.

; This program is not yet finished and requires debugging.

#define MEMORY_SIZE 10240

jmp @_main

#include "include_files/print.asm"
#include "include_files/memstack.asm"

@_main:
    movl    rb      @MEM_PTR        ; initial stack pointer
    jmp     @_set_up_args

    ; get a character from stdin
@_get_next_char:
    movl    rd      '\n'            ; for comparison
    get     ra                      ; get a char
    out     ra                      ; display it
    jeq     ra  rd  @_output        ; char is '\n'? then exit
    push    ra
    jmp     @memstack_push
@_set_up_args:
    movl    ra      @_set_up_args   ; return address
    push    ra
    movr    ra  rb                  ; stack pointer
    push    ra
    movl    ra      0xFFFF          ; stack limit
    push    ra
    jmp     @_get_next_char

@_output:
    movl    rd      @MEM_PTR        ; to tell when we're done
    movl    rc      @_output_loop   ; return address
    push    rc
    push    rb                      ; stack pointer
    jmp     @memstack_pop
@_output_loop:
    out     ra
    jgr     rd  rb  @_main_exit
    jmp     @_output

@_main_exit:
    movl    ra      '\n'
    out     ra
    halt


@MEM_PTR:
    alloc   MEMORY_SIZE
