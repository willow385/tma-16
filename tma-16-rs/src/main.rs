/* Rust implementation of the TMA-16, by {Dante,Claire} Falzone.

Licensed under GNU GPL v3 or later version, as with all my other stuff.

Currently under construction; when finished, it will be up to par with
version 1.2, supporting instructions 0x01 through 0x19.

This implementation will allow you to choose an execution speed delay, or
choose no delay at all; if you didn't have an artificial delay then I'd expect
that the Rust implementation would actually be pretty damn fast, possibly not
too far from running native machine code.

For those of you more concerned with seeing the TMA-16 actually work immediately,
head on up to the parent directory and run the very hacky,
badly-written, quick-and-dirty Python implementation.
*/

use std::env;
use std::fs::File;
use std::fs;
use std::io::Read;

pub mod machine;
pub use machine::*;
use crate::machine::byte_index;

// Function to get the name of the executable from command-line args.
fn get_tmx_name(args: Vec<String>) -> Result<String, &'static str> {
    for arg in args {
        if arg.contains(".tmx") {
            return Ok(String::from(arg));
        }
    }

    Err("no filename ending in `.tmx` was passed")
}

/* Function to check for the `poor` terminal option which is used to tell the
   TMA-16 to only use ASCII chars. */
fn contains_poor_option(args: Vec<String>) -> bool {
    for arg in args {
        if arg == "-p" || arg == "--poor" {
            return true;
            // didn't even know Rust had a 'return` keyword before today lol
        }
    }

    false
}

fn main() -> Result<(), String> {
    let args_vec: Vec<String> = env::args().collect();

    /* never thought I'd be using `.map_err(|e| e.to_string())?` with a
       function I wrote myself lol */
    let tmx_filename = get_tmx_name(args_vec).map_err(|e| e.to_string())?;
    let mut addr_space = fs::read(&tmx_filename).unwrap();
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
        line_height: 0,
    };

    'execute: loop {
        let inst_addr = machine.ip as usize;
        machine.current_instruction = addr_space[inst_addr];
        match machine.current_instruction {
            0x01 => {
                machine.jmp(
                    combine_bytes(
                        addr_space[inst_addr + 1],
                        addr_space[inst_addr + 2]
                    )
                );
                machine._ip_inc(3);
            },

            0x02 => {
                machine.jeq(
                    addr_space[inst_addr + 1],
                    addr_space[inst_addr + 2],
                    combine_bytes(
                        addr_space[inst_addr + 3],
                        addr_space[inst_addr + 4]
                    ),
                    5 // default amount by which to increment ip
                );
            },

            0x03 => {
                machine.jgr(
                    addr_space[inst_addr + 1],
                    addr_space[inst_addr + 2],
                    combine_bytes(
                        addr_space[inst_addr + 3],
                        addr_space[inst_addr + 4]
                    ),
                    5
                );
            },

            0x04 => {
                machine.add(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            0x05 => {
                machine.sub(addr_space[inst_addr + 1], addr_space[inst_addr + 2]);
                machine._ip_inc(3);
            },

            0x06 => {
                machine.read(
                    addr_space[inst_addr + 1],
                    combine_bytes(
                        addr_space[inst_addr + 2],
                        addr_space[inst_addr + 3]
                    ),
                    &addr_space
                );
                machine._ip_inc(4);
            },

            0x07 => {
                machine.write(
                    addr_space[inst_addr + 1],
                    combine_bytes(
                        addr_space[inst_addr + 2],
                        addr_space[inst_addr + 3]
                    ),
                    &mut addr_space
                );
                machine._ip_inc(4);
            },
            
            // TODO: instructions 0x08 through 0x19

            _ => hardware_exception("unrecognized/unimplemented instruction"
                    .to_string())
        }
    }

    Ok(())
}

/*
    Rust won't let you do a naive implementation of anything.
    It forces you to write very robust, high-quality code.
    I'm still not sure if that's an entirely good thing for all cases;
    it certainly makes Rust a terrible choice for introducing someone
    to programming, for example. But overall it's probably for the best
    that, if people are going to write systems-level (and even kernel-level)
    code in pure, safe Rust, they *can't* write a hacky, quick-and-dirty
    implementation.
*/
