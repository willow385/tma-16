# tma-16
A Thouroughly Minimalist Architecture (16-bit)

The TMA-16 is a 16-bit computer of my own design, with a very limited instruction set (only 25 opcodes!).
It was created both as a teaching tool, to help people visualize computation at the lowest level, as well as a learning
tool, to help me have a better grasp of low-level programming and a slightly easier Assembly language to practice with
than x86 Assembly.

You'll want to read `tma-16-rs/README.txt` for a list of options to pass to it.

This implementation, written in Rust, can run TMA-16 executables almost as fast as native machine code, but if you'd
like to be able to see what's going on you can slow down the execution. See `tma-16-rs/README.txt` for more details.

Building the machine (on *nix) is easy, provided your Rust toolchain is up-to-date:
  1. `cd tma-16-rs`

  2. `cargo build`

And that's it! The path to the executable is `tma-16-rs/target/debug/tma-16-rs`. You can make an alias for it or move
it into `/usr/bin` for greater ease of use.

To use this virtual machine, do the following (assuming that `tma-16-rs` is in `/usr/bin` or is aliased):
  1. Use the .asm files in the directory /programs/ (or write your own programs in TMA-16 Assembly!)

  2. Assemble them with `python3 tma_16_assembler.py [file].asm`. Pass the option `-h` or `--hexdump` on the command line to see a
     hexdump of your assembled program.

  3. Run them with `tma-16-rs {file}.tmx [options]` (".tmx" is the extension for TMA-16 executables).

If you would like to make tweaks to the TMA-16, or write a new implementation of it, try running some of the provided programs
(especially test.asm) to make sure that whatever your doing still conforms to the specification.

The Rust implementation is very, very fast and is guaranteed to be memory safe. However, it doesn't yet have super robust error handling
built into it; in many cases it will just panic if the `.tmx` file it's running has errors. This will hopefully be fixed soonish.

If someone wrote a C compiler for the TMA-16, I think it'd be just the coolest thing ever. Not sure that porting `libc` to it would be
super easy, though, since it's a pretty stripped-down 16-bit architecture with a tiny stack and only 4 registers.
