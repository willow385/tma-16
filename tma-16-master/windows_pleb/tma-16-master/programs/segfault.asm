; This program should trigger a segmentation fault
; in a compliant TMA-16 implementation.

write    ra      0xF673  ; this memory address isn't part of the program, so this program can't access it
halt
