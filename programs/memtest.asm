jmp @_main

#include "include_files/memstack.asm"
#include "include_files/print.asm"

#define VALUE 0xFEEB

; for ALLOC_AMOUNT let's give ourselves a little padding
#define ALLOC_AMOUNT 10

@_main:
    movl    ra      @_main_ret0     ; return address
    push    ra
    movl    ra      @bss            ; stack pointer
    push    ra
    movl    rb      ALLOC_AMOUNT
    add     ra  rb                  ; stack limit
    push    ra
    movl    ra      VALUE           ; 16-bit value to push
    push    ra
    jmp     @memstack_push_long
@_main_ret0:
    push    rb                      ; save the stack pointer
    movl    ra      @_main_ret1     ; return address
    push    ra
    movl    ra      @msg0           ; string to print
    push    ra
    jmp             @print_string
@_main_ret1:
    pop     rb                      ; remember the stack pointer?
    movl    ra      @_main_ret2     ; return address
    push    ra
    push    rb                      ; stack pointer again
    jmp             @memstack_pop_long
@_main_ret2:
    ; VALUE should be in register A, so don't clobber it
    movl    rb      @_main_ret3     ; return address
    push    rb
    push    ra                      ; number to print
    jmp             @print_u16
@_main_ret3:
    movl    rb      '\n'
    out     rb
    halt


@bss:
    alloc   ALLOC_AMOUNT

@msg0:
    pb      "Va"
    pb      "lu"
    pb      "e\s"
    pb      "pu"
    pb      "sh"
    pb      "ed"
    pb      "\n\0"
