use std::process;

// Function to stop the TMA-16 in various scenarios.
fn hardware_exception(error_msg: String) {
    println!("Error! {}", error_msg);
    println!("TMA-16 core dumped");
    process::exit(1);
}

// Struct in which the machine's state is held.
pub struct Tma16 {
    // registers
    ra: u16,
    rb: u16,
    rc: u16,
    rd: u16,

    // instruction pointer
    ip: u16,

    // stack
    stack: [u16; 16],

    // stack flag
    stack_flag: u8,

    // other important stuff
    current_instruction: u8,
    stdout: String,
    line_height: u32,
}

impl Tma16 {
    pub fn reg_val(&self, num: u8) -> Result<u16, ()> {
        match num {
            0x0A => Ok(self.ra),
            0x0B => Ok(self.rb),
            0x0C => Ok(self.rc),
            0x0D => Ok(self.rd),
            0x0E => Ok(self.ip),
            _ => Err(
                    hardware_exception(
                        format!("nonexistent register {:x?}", num)
                    .to_string()
                    )
                )
        }
    }

    pub fn movl(&mut self, reg: u8, value: u16) -> Result<(), ()> {
        match reg {
            0x0A => { self.ra = value; Ok(()) },
            0x0B => { self.rb = value; Ok(()) },
            0x0C => { self.rc = value; Ok(()) },
            0x0D => { self.rd = value; Ok(()) },
            _ => Err(
                    hardware_exception(
                        format!("illegal instruction operand {:x?}", reg)
                        .to_string()
                    )
                )
        }
    }
}
