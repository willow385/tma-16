use std::process;
use std::env;

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

    println!("{}", tmx_filename);

    Ok(())
}
