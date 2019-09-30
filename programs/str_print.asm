jmp 0x0003

; procedure to print a string
; memory address of string's first char
; must be on top of the stack and ra must be
; available for free use
pop     ra      ; contains pointer to start of string
; TODO: add an instruction allowing you to read a runtime-determined memory address

halt
