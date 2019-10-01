# tma-16
A Thouroughly Minimalist Architecture (16-bit)

The TMA-16 is a 16-bit computer of Dante's own design, with a very limited instruction set (only 23 opcodes!).
It was created both as a teaching tool, to help people visualize computation at the lowest level, as well as a learning
tool, to help Dante have a better grasp of low-level programming and a slightly easier Assembly language to practice with
than x86 Assembly. As of 29 Sept 2019 it has an artificial delay built into it to make it easier to see what's going on,
which gives it a processing speed of 5 cycles per second plus whatever latency the Python interpreter adds.

To assemble programs on Windows:
  1. Open `tma_16_assembler_WIN.py` with Python 3.

  2. Type the name of the file you wish to assemble and press ENTER. For example `programs\test.asm`

To run assembled programs:
  1. Open `tma_16_WIN.py` with Python 3.

  2. Type the name of the program to execute and press ENTER. For example `programs\test.tmx`

  3. When the program stops running you can press ENTER to turn off the virtual machine.

If you would like to make tweaks to the TMA-16, or write a new implementation of it, try running some of the provided programs
(especially test.asm) to make sure that whatever your doing still conforms to the specification.

TODO: write more complete and detailed documentation; make a less messy implementation, ideally in a performance language like
Rust or C.

If someone wrote a C compiler for the TMA-16, I think it'd be just the coolest thing ever.
