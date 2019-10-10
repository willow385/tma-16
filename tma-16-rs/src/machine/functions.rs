use std::process;

/**
 * Function to print an error message and halt immediately if something
 * happens that should never happen.
 * @param error_msg the error message to print out
 */
pub fn hardware_exception(error_msg: String) -> () {
    println!("Error! {}", error_msg);
    println!("TMA-16 core dumped");
    process::exit(1);
}

/**
 * Function to get the indexth bit of a 16-bit value in very few clock cycles,
 * where the 0th bit is the least significant bit and the 15th is the most
 * significant bit.
 *
 * Triggers an exception if you try to access a nonexistent bit.
 *
 * @param index the bit to return
 * @param byte the value from whence to extract the bit
 * @return std::result::Result<>, ideally containing the bit we want
 */
pub fn byte_index(index: u8, byte: u16) -> Result<u8, ()> {
    if index > 15 {
        return Err(hardware_exception("Only unsigned 16-bit values allowed"
            .to_string()));
    }

    let bit: u8 = ((byte >> (index as u16)) & (1 as u16)) as u8;
    Ok(bit)
}

/**
 * Function to very quickly combine two 8-bit values into one 16-bit value.
 *
 * @param byte_0 the most significant 8 bits
 * @param byte_1 the least significant 8 bits
 * @return the two values smushed together
 */
pub fn combine_bytes(byte_0: u8, byte_1: u8) -> u16 {
    let byte_0_shifted: u16 = (byte_0 as u16) << 8;
    byte_0_shifted | (byte_1 as u16)
}
