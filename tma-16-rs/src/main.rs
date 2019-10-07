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
pub use machine::Tma16;

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
            return true; // didn't even know Rust had a `return` keyword before today lol
        }
    }

    false
}

fn main() -> Result<(), String> {
    let args_vec: Vec<String> = env::args().collect();

    /* never thought I'd be using `.map_err(|e| e.to_string())?` with a
       function I wrote myself lol */
    let tmx_filename = get_tmx_name(args_vec).map_err(|e| e.to_string())?;
    let file_buf = fs::read(&tmx_filename).unwrap();

    /* Haven't yet implemented the actual gotdamn machine yet, so for now all this does
       is hexdump .tmx files, which isn't totally useless but... eh. */
    println!("{}", tmx_filename);
    for i in file_buf {
        if i < 0x10 {
            println!("0{:x?}", i);
        } else {
            println!("{:x?}", i);
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
