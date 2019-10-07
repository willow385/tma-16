use std::process;
use std::env;
use std::fs::File;
use std::fs;
use std::io::Read;

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
        }
    }

    false
}

// Function to read the contents of a binary file up to 64KB in size.
fn get_file_as_byte_vec(filename: &String) -> Vec<u8> {
    let mut f = File::open(&filename).expect("no file found");
    let metadata = fs::metadata(&filename).expect("unable to read metadata");
    let mut buffer = vec![0; metadata.len() as usize];
    f.read(&mut buffer).expect("buffer overflow");

    if metadata.len() > 0xFFFF {
        panic!("Oversized executable");
    }

    buffer
}

// Function to stop the TMA-16 in various scenarios.
fn hardware_exception(error_msg: String) {
    println!("Error! {}", error_msg);
    println!("TMA-16 core dumped");
    process::exit(1);
}



fn main() -> Result<(), String> {
    let args_vec: Vec<String> = env::args().collect();

    /* never thought I'd be using `.map_err(|e| e.to_string())?` with a
       function I wrote myself lol */
    let tmx_filename = get_tmx_name(args_vec).map_err(|e| e.to_string())?;
    let file_buf: Vec<u8> = get_file_as_byte_vec(&tmx_filename);

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
