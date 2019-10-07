/* rust implmentation that I wrote while drunk lmaooooooooooooooooo*/

use std::process;

fn hardware_exception(String error_msg) {
    println!("Error! {error_msg}");
    println!("TMA-16 core dumped");
    process::exit(1);
}

fn main() {

