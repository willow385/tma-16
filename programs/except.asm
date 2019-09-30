; This program is written to trigger a ``hardware'' exception.
; A correct implementation of this version of the TMA-16 should
; detect that you're trying to store a value in a register too
; big for 16 bits, and stop immediately with an error message.

movl     ra   0xFFFF
movl     rb   0x1
add      ra   rb
halt
