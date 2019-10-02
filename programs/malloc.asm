; Unfortunately this isn't a full-fledged implementation of malloc().
; This is just a test to see if the feature added to version 1.1 of the assembler works.

alloc   100     ; should result in the executable containing 100 null bytes
halt
