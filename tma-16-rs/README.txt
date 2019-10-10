*** List of options you can pass to the Rust implementation of the TMA-16 ***

(since I don't want to write a proper man page for it just yet)

OPTION          BEHAVIOUR

--delay n       Sleep for n milliseconds before executing each instruction.

--list          List the instructions as they are being executed, one by one.
                Recommended to use only when paired with the option "--no-display".

--no-display    Don't show an animated diagram of the machine's internal state.
                (The machine will show such a diagram if this option is not passed.)

--report        Print a report of the machine's internal state when execution
                finishes. 
