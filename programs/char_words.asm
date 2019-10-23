; This program prints a short message to test the new char word literal feature
; in the assembler.

movl    rc      @string_start ; rc now contains a pointer to the first char of the string
xor     ra      ra            ; zero out ra (xor is fewer bytes than movl)

@loop_repeat:
    readr   rb      rc            ; fetch the byte pointed to by rc
    jeq     rb  ra  @exit_point   ; byte is a null char? then we've reached the end of the string
    out     rb                    ; else output it and continue
    inc     rc                    ; change the pointer to point to the next char
    jmp     @loop_repeat          ; go back up to the readr operation

@exit_point:
    halt

@string_start:
    pb "Sy"
    pb "nt"
    pb "ac"
    pb "ti"
    pb "c\s"
    pb "su"
    pb "ga"
    pb "r\s"
    pb "is"
    pb "\sf"
    pb "un"
    pb "\sa"
    pb "nd"
    pb "\sc"
    pb "oo"
    pb "l\n"
    pb 0
