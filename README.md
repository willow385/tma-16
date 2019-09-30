# tma-16
A Thouroughly Minimalist Architecture (16-bit)

The TMA-16 is a 16-bit computer of Dante's own design, with a very limited instruction set (only 23 opcodes!).
It was created both as a teaching tool, to help people visually computation at the lowest level, as well as a learning
tool, to help Dante have a better grasp of low-level programming and a slightly easier Assembly language to practice with
than x86 Assembly. As of 29 Sept 2019 it has an artificial delay built into it to make it easier to see what's going on,
which gives it a processing speed of 5 cycles per second plus whatever latency the Python interpreter adds.

To use this virtual machine, do the following:
  1. Use the .asm files in the directory /programs/ (or write your own programs in TMA-16 Assembly!)
  
  2. Assemble them with `python3 tma_16_assembler.py [file].asm`. Pass the option `-h` or `--hexdump` on the command line to see a 
     hexdump of your assembled program.

  3. Run them with `python3 tma_16.py [file].tmx` (".tmx" is the extension for TMA-16 executables). If your terminal doesn't
     support unicode, pass the option `-p` or `--poor`.

If you would like to make tweaks to the TMA-16, or write a new implementation of it, try running some of the provided programs
(especially test.asm) to make sure that whatever your doing still conforms to the specification.

TODO: write more complete and detailed documentation; make a less messy implementation, ideally in a performance language like
Rust or C.

If someone wrote a C compiler for the TMA-16, I think it'd be just the coolest thing ever.
