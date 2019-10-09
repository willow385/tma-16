; Program that prints eight newline characters.
; Written to test the virtual machine's internal state display
; to see if a changing number of lines causes it to choke.

#define LOOP_REPEAT 0x000B

movl    rc      8
xor     rd      rd
movl    ra      10

out     ra
dec     rc
jgr     rc  rd  LOOP_REPEAT

halt
