/* Rust implementation of the TMA-16, by {Dante,Claire} Falzone.

Licensed under GNU GPL v3 or later version, as with all my other stuff.

This implementation supports version 1.2 of the TMA-16 instruction set.

This implementation runs TMA-16 machine code almost as fast as native code, thanks
no doubt in large part to the Rust compiler's powerful optimization algorithm.

This implementation doesn't YET have an animated internal state diagram like the
original implementation does. If you want to see what's going on under the hood
in real time, head on up to the parent directory and run the very hacky,
badly-written, quick-and-dirty Python implementation.

IMPORTANT TODO: Document all of the implementation-specific options that this
implementation of the TMA-16 has. Also finish writing the part to show an animated
display of the internals.
*/

use std::env;
use std::fs;
use std::{thread, time};

pub mod machine;
pub use machine::*;

// Function to get the name of the executable from command-line args.
fn get_tmx_name(args: &Vec<String>) -> Result<String, &'static str> {
    for arg in args {
        if arg.contains(".tmx") {
            return Ok(String::from(arg));
        }
    }

    Err("no filename ending in `.tmx` was passed")
}

// Function to check whether the args contain a certain string.
fn contains_option(args: &Vec<String>, option: String) -> bool {
    for arg in args {
        if *arg == option {
            return true;
            // didn't even know Rust had a 'return` keyword before today lol
        }
    }

    false
}

// Function to get the time delay option.
fn get_time_delay(args: &Vec<String>) -> u64 {
    if contains_option(args, String::from("--delay")) {
        let delay_arg_index = args.iter().position(|a| a == "--delay").unwrap();
        args[delay_arg_index + 1].parse::<u64>().unwrap()
    } else {
        0
    }
}

fn main() -> Result<(), String> {
    // First we put the command-line args into a vector of strings.
    let args_vec: Vec<String> = env::args().collect();

    // Then we parse the args to get the name of the executable we want to run.
    let tmx_filename = get_tmx_name(&args_vec).map_err(|e| e.to_string())?;

    /* We read the file's contents into a vector of unsigned bytes, which will be
    used as the "address space" in which the machine's main memory resides. */
    let mut addr_space = fs::read(&tmx_filename).unwrap();

    // Here we create an instantiation of the machine.
    let mut machine = Tma16 {
        ra: 0,
        rb: 0,
        rc: 0,
        rd: 0,
        ip: 0,
        stack: [0; 16],
        stack_pointer: 0,
        stack_flag: 0,
        current_instruction: 0,
        stdout: String::from(""),
        line_height: 24,
    };

    // This arg tells us whether or not to print out the instructions one by one.
    // This is presumably faster than calling contains_option() each loop.
    let list_instructions = contains_option(&args_vec, String::from("--list"));

    // This arg tells us whether or not to print the contents of the registers and stack.
    let state_report = contains_option(&args_vec, String::from("--report"));

    // This arg tells us whether or not to show an animated diagram of the machine's state.
    let display_not_suppressed = !contains_option(&args_vec, String::from("--no-display"));

    /* Parse the args for the "--delay" option. If none is passed, or "--delay 0" is passed,
    we won't be delaying at all. */
    let time_delay = time::Duration::from_millis(get_time_delay(&args_vec) * 100);

    /* This is the fetch-decode-execute loop, although not quite, since decode and execute
    aren't two separate things in this implementation. */
    'execute: loop {
        thread::sleep(time_delay);

        if display_not_suppressed { poor_print_machine(&machine) };

        let inst_addr = machine.ip as usize; // For indexing the program's main memory.
        machine.current_instruction = addr_space[inst_addr];

        if list_instructions {
            if machine.current_instruction < 0x10 {
                println!("Instruction: 0{:X?}", machine.current_instruction);
            } else {
                println!("Instruction: {:X?}", machine.current_instruction);
            }
        }

        // Pick one of several actions depending on the presently selected byte.
        // XXX: This is a very long match block; any way to make this more concise?
        match machine.current_instruction {

            // Unconditional jump instruction.
            0x01 => {
                machine.jmp(
                    // destination address
                    combine_bytes(
                        addr_space[inst_addr + 1],
                        addr_space[inst_addr + 2]
                    )
                );
            },

            // Jump-if-equal: jump if two registers have equal values in them.
            0x02 => {
                machine.jeq(
                    // first register
                    addr_space[inst_addr + 1],

                    // second register
                    addr_space[inst_addr + 2],

                    // destination address
                    combine_bytes(
                        addr_space[inst_addr + 3],
                        addr_space[inst_addr + 4]
                    ),
                    5 // if regs aren't equal, we increment the inst ptr by this much
                );
            },

            // Jump-if-greater: jump if one register is greater than another.
            0x03 => {
                machine.jgr(
                    // first register
                    addr_space[inst_addr + 1],

                    // second register
                    addr_space[inst_addr + 2],

                    // destination address
                    combine_bytes(
                        addr_space[inst_addr + 3],
                        addr_space[inst_addr + 4]
                    ),
                    5
                );
            },

            // Add: store the sum of two registers in the first register.
            0x04 => {
                machine.add(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            /* Subtract: store the absolute value of the difference of two registers in
            the first register. */
            0x05 => {
                machine.sub(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            // Read: copy a value from somewhere in main memory into a register.
            0x06 => {
                machine.read(
                    // destination register
                    addr_space[inst_addr + 1],

                    // address to fetch from
                    combine_bytes(
                        addr_space[inst_addr + 2],
                        addr_space[inst_addr + 3]
                    ),

                    // address space to get value from
                    &addr_space
                );
                machine._ip_inc(4);
            },

            // Write: write the lowest 8 bits of a register to somewhere in main memory.
            0x07 => {
                machine.write(
                    // source register
                    addr_space[inst_addr + 1],

                    // destination address
                    combine_bytes(
                        addr_space[inst_addr + 2],
                        addr_space[inst_addr + 3]
                    ),

                    // address space to write value to
                    &mut addr_space
                );
                machine._ip_inc(4);
            },

            // Move register: copy a value from one register into another.
            0x08 => {
                machine.movr(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            // Move literal: store a literal value in a register.
            0x09 => {
                machine.movl(
                    // destination register
                    addr_space[inst_addr + 1],

                    // value
                    combine_bytes(
                        addr_space[inst_addr + 2],
                        addr_space[inst_addr + 3]
                    )
                );
                machine._ip_inc(4);
            },

            // Bitwise and: perform the "and" op on two registers.
            0x0A => {
                machine.and(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            // Bitwise or: perform the "or" op on two registers.
            0x0B => {
                machine.or(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            // Bitwise xor: perform the "xor" op on two registers.
            0x0C => {
                machine.xor(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            // Bitwise not: perform the "not" operation on a register.
            0x0D => {
                machine.not(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Output: print the value in a register as an ascii char to stdout.
            0x0E => {
                machine.out(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Halt: stop running.
            0x0F => {
                machine.halt();
                break 'execute;
            },

            // Push: attempt to push a byte onto the stack.
            0x10 => {
                machine.push(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Pop: take a byte off of the stack.
            0x11 => {
                /* 0x0E represents the instruction pointer which is singled out here
                because it can't be used as an operand for most register operations
                (lest a naive programmer use it as general-purpose and create a program
                that jumps all over the goddamn place.) Popping a byte into the instruction
                pointer is allowed because jumping to an address stored on the stack
                would be necesssary for writing subroutines in TMA-16 assembly. */
                if addr_space[inst_addr + 1] == 0x0E {
                    machine.pop(0x0E);
                } else {
                    machine.pop(addr_space[inst_addr + 1]);
                    machine._ip_inc(2);
                }
            },

            // Overflow: copy the value of the stack overflow flag into a register.
            0x12 => {
                machine.ovrf(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Clear overflow: reset the stack overflow flag to zero.
            0x13 => {
                machine.clrovr();
                machine._ip_inc(1);
            },

            /* Read register: copy into a register the value pointed to by the address stored
            in another register. */
            0x14 => {
                machine.readr(
                    addr_space[inst_addr + 1],
                    addr_space[inst_addr + 2],
                    &addr_space
                );
                machine._ip_inc(3);
            },

            // Increment: increase the value of a register by one.
            0x15 => {
                machine.inc(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Decrement: decrease the value of a register by one.
            0x16 => {
                machine.dec(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            /* Write register: using the value in a register as the destination address, write
            the value stored in another register to main memory. */
            0x17 => {
                machine.writr(
                    addr_space[inst_addr + 1],
                    addr_space[inst_addr + 2],
                    &mut addr_space
                );
                machine._ip_inc(3);
            },

            // Bitshift left: shift the bits in a register one place higher.
            0x18 => {
                machine.bsl(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            // Bitshift right: shift the bits in a register one place higher.
            0x19 => {
                machine.bsr(addr_space[inst_addr + 1]);
                machine._ip_inc(2);
            },

            /* If the currently selected instruction isn't a number from 0x01 to 0x19, then it's
            not a valid TMA-16 machine instruction, so it's time to trigger a hardware
            exception and dump the core. */
            _ => hardware_exception("unrecognized/unimplemented instruction"
                    .to_string())
        }

        if display_not_suppressed { clear_screen(&machine) };
    }

    // TODO: implement animated internal state diagram like the Python implementation has.

    /* Whatever was output to the TMA-16's serial tty, print it to the host machine's actual
    standard output. */
    if !display_not_suppressed {
        for c in machine.stdout.chars() {
            print!("{}", c);
        }
    }

    /* Print out a description of the machine's internal state at the time it halted if the option
    "--report" was passed on the command line. */
    if state_report {
        if machine.ip < 0x10 {
            println!("Program terminated at address 0{:X?} with no errors", machine.ip);
        } else {
            println!("Program terminated at address {:X?} with no errors", machine.ip);
        }
        
        println!("RA: {:X?}", machine.ra);
        println!("RB: {:X?}", machine.rb);
        println!("RC: {:X?}", machine.rc);
        println!("RD: {:X?}", machine.rd);

        print!("Stack:");
        for byte in machine.stack.iter() {
            print!(" {:X?}", byte);
        }
        print!("\n");

        if machine.stack_flag != 0 {
            println!("Stack overflow flag was set");
        }
    }

    Ok(())
}

// Function to convert a 16-bit value to a 4-digit hexadecimal representation
fn hex_to_str(hex: u16) -> String {
    if hex > 0xFFF {
        String::from(format!("{:X?}", hex))
    } else if hex > 0xFF {
        String::from(format!("0{:X?}", hex))
    } else if hex > 0xF {
        String::from(format!("00{:X?}", hex))
    } else {
        String::from(format!("000{:X?}", hex))
    }
}

// Function to go back up to redraw the diagram
fn clear_screen(m: &Tma16) {
    for _i in 0..(m.line_height) {
        print!("\x1b[A");
    }
}

// Function to print a diagram of the machine's internals with ascii chars only
fn poor_print_machine(m: &Tma16) {
    println!("\r   Registers:");
    println!("                Binary                Hex");

    for reg_id in 0xA..0xE {
        println!("   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +----+");
        print!("   |");
        let mut i: i8 = 15;
        while i >= 0 {
            print!("{}|", byte_index(i as u8, m.reg_val(reg_id).unwrap()).unwrap());
            i -= 1;
        }
        println!(" |{}|", hex_to_str(m.reg_val(reg_id).unwrap()));
    }

    println!("   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +----+\n");
    println!("Stack:");
    for _i in 0..16 {
        print!("+----");
    }
    print!("+\n|");
    for byte in m.stack.iter() {
        print!("{}|", hex_to_str(*byte));
    }

    if m.stack_flag == 1 {
        println!(" STACK OVERFLOW");
    } else {
        println!("               "); // to overwrite "STACK OVERFLOW" if it was set
    }
    for _i in 0..16 {
        print!("+----");
    }
    print!("+\n\n");
    println!("                    +----+");
    println!("Instruction Pointer |{}|", hex_to_str(m.ip));
    println!("                    +----+");
    println!("Current Instruction |{}|", hex_to_str(m.current_instruction as u16));
    println!("                    +----+");
    println!("Stdout:");
    println!("{}", m.stdout);
    for c in m.stdout.chars() {
        if c == '\n' {
            print!("\x1b[A");
        }
    }
}
