; Program that prints eight newline characters.
; Written to test the virtual machine's internal state display
; to see if a changing number of lines causes it to choke.

movl    rc      8
xor     rd      rd
movl    ra      10

@loop_repeat:
    out     ra
    dec     rc
    jgr     rc  rd  @loop_repeat

halt
