# Contributing Guidelines

Since this project is starting to get a little traffic I thought I'd write some contributing guidelines.

Contributing code to the virtual machine
* If you find a bug in the VM implementation, feel free to raise an Issue in the matter or submit a pull request with a patch.
* If you want a new feature added to the TMA-16's instruction set, or a new implementation feature, it is preferred that you should raise an Issue about it to explain why this feature is a good idea before submitting a pull request. However, this isn't a strict rule.
* I am not personally interested in writing or maintaining a Windows implementation while I'm still in school, but if someone else wants to that's great. I request only that you make it clear which version of the TMA-16 instruction set your implementation supports (ideally the latest version).
* Pull requests to make the VM implementation faster, cleaner, or otherwise better-written are definitely welcome.

Contributing TMA-16 Assembly programs
* If you want to contribute a program written in TMA-16 Assembly, that's great! But please write it for the latest version of the assembler, and please test/debug it with the latest version of the VM. I wouldn't be surprised if the VM or the assembler had an implementation bug that I simply haven't found yet, but please assume when testing that the problem is in your program, not in the implementation.
* Please don't ask me to write a program in TMA-16 Assembly. I've written many of them and I will write more, but if there's one that *you* want in particular then try taking a crack at it yourself first.

Contributing to the toolchain
* The disassembler doesn't entirely work. I don't personally consider the disassembler a high priority but if you want to try to fix it go ahead.
* The assembler *does* entirely work, but it is very badly written. I'm hoping to rewrite it at some point. Please feel free to submit a patch for it.
* If you want to write another program as part of the toolchain, feel free to submit a pull request. A linker and a debugger would be really cool, and I will get around to writing them *eventually* if no one else wants to. Don't hold your breath for it though.

Everything else
* All other contributions, in the form of a pull request or an Issue, are welcome. :)
