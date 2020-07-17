; FizzBuzz in TMA-16 Assembly
; Assemble with tmasm and run on the TMA-16 virtual machine

jmp @main

; For the hell of it, I've written this program to not rely
; on any of the subroutines in include_files/. It is a wholly
; standalone program.

@main:
    xor     ra  ra  ; loop counter starts at 0
; Check to see if the loop counter is divisible by 15
@_main_loop0:
    movl    rb      15
    movl    rc      @_main_ret_addr0
    push    rc      ; return address
    push    rb      ; divisor
    push    ra      ; number to divide
    jmp             @is_divisible
@_main_ret_addr0:
    pop     rd ; rd contains 1 if ra is divisible by 15, else 0
    movl    rc      1
    jeq     rc  rd  @_main_number_mod_15 ; print FizzBuzz
; control flow comes here if the number is not divisible by 15
    movl    rb      5
    movl    rc      @_main_ret_addr1
    push    rc      ; return address
    push    rb      ; divisor
    push    ra      ; number to divide
    jmp             @is_divisible
@_main_ret_addr1:
    pop     rd ; similar to @_main_ret_addr0
    movl    rc      1
    jeq     rc  rd  @_main_number_mod_5 ; print Buzz
; control flow comes here if the number is not divisible by 5
    movl    rb      3
    movl    rc      @_main_ret_addr2
    push    rc      ; return address
    push    rb      ; divisor
    push    ra      ; number to divide
    jmp             @is_divisible
@_main_ret_addr2:
    pop     rd
    movl    rc      1
    jeq     rc  rd  @_main_number_mod_3
    jmp             @_main_print_number
@_main_number_mod_15:
    ; print Fizz
    movl    rc      @_main_number_mod_15_print_buzz
    push    rc
    jmp             @fizz
@_main_number_mod_15_print_buzz:
    movl    rc      @_main_repeat_loop
    push    rc
    jmp             @buzz
@_main_number_mod_5:
    movl    rc      @_main_repeat_loop
    push    rc
    jmp             @buzz
@_main_number_mod_3:
    movl    rc      @_main_repeat_loop
    push    rc
    jmp             @fizz
@_main_print_number:
    movl    rc      @_main_repeat_loop
    push    rc
    movr    rc  ra
    push    rc
    jmp             @print_number
@_main_repeat_loop:
    ; print a newline, update our loop counter, and continue unless ra == 101
    movl    rc      '\n'
    out     rc
    movl    rb      101
    inc     ra
    jgr     rb  ra  @_main_loop0
    halt


; Subroutine to check if a number is divisible by another number.
; Push the return address, then the divisor, then the number you want to divide by it,
; before jumping here. It will leave 1 on the stack if the number is divisible
; by the divisor, and 0 otherwise.
; If this was C the prototype for this might look something like this:
; unsigned short is_divisible(unsigned short number, unsigned short divisor);
@is_divisible:
    pop     rb          ; number to divide
    pop     rc          ; divisor
    push    ra
    xor     ra  ra      ; zero
    jeq     rb  ra  @_is_not_divisible ; we can skip a few instructions if number is zero
@_is_divisible_loop0:
    add     ra  rc
    jgr     ra  rb  @_is_not_divisible
    jeq     ra  rb  @_is_divisible
    jmp             @_is_divisible_loop0
@_is_not_divisible:
    pop     ra
    movl    rd      0
    pop     rc          ; return address
    push    rd
    push    rc
    pop     ip
@_is_divisible:
    pop     ra
    movl    rd      1
    pop     rc
    push    rd
    push    rc
    pop     ip


; Subroutine to print "Fizz"
@fizz:
    push    ra
    movl    ra      'F'
    out     ra
    movl    ra      'i'
    out     ra
    movl    ra      'z'
    out     ra
    out     ra
    pop     ra
    pop     ip


; Subroutine to print "Buzz"
@buzz:
    push    ra
    movl    ra      'B'
    out     ra
    movl    ra      'u'
    out     ra
    movl    ra      'z'
    out     ra
    out     ra
    pop     ra
    pop     ip


; Subroutine to print a number >=0 and <100. Nothing super clever here,
; basically just "puts(ra + (rb << 1));"
@print_number:
    pop     rb      ; offset
    bsl     rb      ; multiply offset by two
    push    ra
    movl    ra      @_numeral_table
    add     ra  rb
    readr   rc  ra  ; rc = *(ra + rb)
    out     rc
    inc     ra
    readr   rc  ra
    out     rc
    pop     ra
    pop     ip

@_numeral_table:
    ; Table of numerals to print
    "0\0"
    "1\0"
    "2\0"
    "3\0"
    "4\0"
    "5\0"
    "6\0"
    "7\0"
    "8\0"
    "9\0"
    "10"
    "11"
    "12"
    "13"
    "14"
    "15"
    "16"
    "17"
    "18"
    "19"
    "20"
    "21"
    "22"
    "23"
    "24"
    "25"
    "26"
    "27"
    "28"
    "29"
    "30"
    "31"
    "32"
    "33"
    "34"
    "35"
    "36"
    "37"
    "38"
    "39"
    "40"
    "41"
    "42"
    "43"
    "44"
    "45"
    "46"
    "47"
    "48"
    "49"
    "50"
    "51"
    "52"
    "53"
    "54"
    "55"
    "56"
    "57"
    "58"
    "59"
    "60"
    "61"
    "62"
    "63"
    "64"
    "65"
    "66"
    "67"
    "68"
    "69"
    "70"
    "71"
    "72"
    "73"
    "74"
    "75"
    "76"
    "77"
    "78"
    "79"
    "80"
    "81"
    "82"
    "83"
    "84"
    "85"
    "86"
    "87"
    "88"
    "89"
    "90"
    "91"
    "92"
    "93"
    "94"
    "95"
    "96"
    "97"
    "98"
    "99"
