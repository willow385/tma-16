; This program prints a short message to test the new char word literal feature
; in the assembler.

#define STRING_START 0x0017
#define LOOP_REPEAT  0x0007
#define EXIT_POINT   0x0016

movl    rc      STRING_START ; rc now contains a pointer to the first char of the string
xor     ra      ra           ; zero out ra (xor is fewer bytes than movl)
readr   rb      rc           ; fetch the byte pointed to by rc
jeq     rb  ra  EXIT_POINT   ; byte is a null char? then we've reached the end of the string
out     rb                   ; else output it and continue
inc     rc                   ; change the pointer to point to the next char
jmp     LOOP_REPEAT          ; go back up to the readr operation

halt

; STRING_START points to right here
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
