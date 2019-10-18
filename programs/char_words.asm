; This program prints a short message to test the new char word literal feature
; in the assembler.

#define STRING_START 0x0017
#define LOOP_REPEAT  0x0007
#define EXIT_POINT   0x0016

movl    rc      STRING_START
xor     ra      ra
readr   rb      rc
jeq     rb  ra  EXIT_POINT
out     rb
inc     rc
jmp     LOOP_REPEAT

halt

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
