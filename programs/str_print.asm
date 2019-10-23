; program to print a hardcoded string to the TMA-16's stdout

xor     rd      rd               ; for comparing to see if we've hit a null char yet
movl    rb      @string_ptr      ; address where the string starts
inc     rb                       ; whoops, the string actually starts one byte later lol

@fetch_char:
    readr   ra      rb               ; find the address pointed to by rb and store its value in ra
    jeq     ra rd   @halt            ; if it's '\0', then go to the `halt` instruction
    out     ra                       ; otherwise, print to stdout
    inc     rb                       ; inc string pointer by 2 since char literals are 2 bytes wide
    inc     rb
    jmp     @fetch_char              ; go back to the "readr" instruction

@halt:
    halt


; Now you can put as many letters here as the TMA-16 can address!
; If you really wanted you could put almost 32KB of text here.
@string_ptr:
    pb      'T'
    pb      'h'
    pb      'i'
    pb      's'
    pb      '\s'
    pb      'p'
    pb      'r'
    pb      'o'
    pb      'g'
    pb      'r'
    pb      'a'
    pb      'm'
    pb      '\s'
    pb      'w'
    pb      'a'
    pb      's'
    pb      '\s'
    pb      'w'
    pb      'r'
    pb      'i'
    pb      't'
    pb      't'
    pb      'e'
    pb      'n'
    pb      '\s'
    pb      'i'
    pb      'n'
    pb      '\s'
    pb      'T'
    pb      'M'
    pb      'A'
    pb      '-'
    pb      '1'
    pb      '6'
    pb      '\s'
    pb      'A'
    pb      's'
    pb      's'
    pb      'e'
    pb      'm'
    pb      'b'
    pb      'l'
    pb      'y'
    pb      '\s'
    pb      'b'
    pb      'y'
    pb      '\s'
    pb      'D'
    pb      'a'
    pb      'n'
    pb      't'
    pb      'e'
    pb      '\s'
    pb      'F'
    pb      'a'
    pb      'l'
    pb      'z'
    pb      'o'
    pb      'n'
    pb      'e'
    pb      '\n'
    pb      0

