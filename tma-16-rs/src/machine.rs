pub mod functions;
pub use crate::functions::*;

// Struct in which the machine's state is held.
pub struct Tma16 {
    // registers
    pub ra: u16,
    pub rb: u16,
    pub rc: u16,
    pub rd: u16,

    // instruction pointer
    pub ip: u16,

    // stack
    pub stack: [u16; 16],
    pub stack_pointer: u8,

    // stack flag
    pub stack_flag: u8,

    // other important stuff
    pub current_instruction: u8,
    pub stdout: String,
    pub line_height: u32,
}

impl Tma16 {
    /**
     * Function that returns the value contained in a register.
     *
     * Panics if a nonexistent register is selected.
     *
     * @param num a number from 0xA to 0xE which selects a register
     * @return the value presently stored in that register
     */
    pub fn reg_val(&self, num: u8) -> Result<u16, ()> {
        match num {
            0x0A => Ok(self.ra),
            0x0B => Ok(self.rb),
            0x0C => Ok(self.rc),
            0x0D => Ok(self.rd),
            _ => Err(
                    hardware_exception(
                        format!("nonexistent register {:x?}", num)
                    .to_string()
                    )
                )
        }
    }

    /**
     * Function that returns a mutable reference to a register.
     *
     * Panics if a nonexistent register is selected.
     *
     * @param id a number from 0xA to 0xE which selects one of the registers
     * @return mutable reference to the selected register
     */
    pub fn reg_ptr(&mut self, id: u8) -> Result<&mut u16, ()> {
        match id {
            0x0A => Ok(&mut self.ra),
            0x0B => Ok(&mut self.rb),
            0x0C => Ok(&mut self.rc),
            0x0D => Ok(&mut self.rd),
            _ => Err(
                   hardware_exception(
                        format!("Register {:x?} does not exist", id)
                    .to_string()
                    )
                )
        }
    }

    /**
     * Function that's NOT part of the instruction set, which increments the
     * instruction pointer.
     *
     * @param bytes how much to increment
     */
    pub fn _ip_inc(&mut self, bytes: u16) {
        self.ip += bytes;
    }

    /* The following functions are invoked by the virtual machine whenever it reads
     a valid TMA-16 machine code instruction.

     For enhanced readability, pretend that all the `.unwrap()`s aren't there.   */

    // jmp: unconditionally change the instruction pointer.
    pub fn jmp(&mut self, dest: u16) {
        self.ip = dest;
    }

    // jeq: jump if the two specified registers are equal.
    pub fn jeq(&mut self, reg_0: u8, reg_1: u8, dest: u16, default_jmp: u16) {
        if self.reg_val(reg_0).unwrap() == self.reg_val(reg_1).unwrap() {
            self.ip = dest;
        } else {
            self.ip += default_jmp;
        }
    }

    // jgr: jump if the first register is greater than the other.
    pub fn jgr(&mut self, reg_0: u8, reg_1: u8, dest: u16, default_jmp: u16) {
        if self.reg_val(reg_0).unwrap() > self.reg_val(reg_1).unwrap() {
            self.ip = dest;
        } else {
            self.ip += default_jmp;
        }
    }

    // add: store the sum of two registers in the first register.
    pub fn add(&mut self, reg_0: u8, reg_1: u8) {
        *self.reg_ptr(reg_0).unwrap()
            = self.reg_val(reg_0).unwrap() + self.reg_val(reg_1).unwrap();
    }

    // sub: store the abs val of the diff of two regs in the first reg.
    pub fn sub(&mut self, reg_0: u8, reg_1: u8) {
        if self.reg_val(reg_0).unwrap() >= self.reg_val(reg_1).unwrap() {
            *self.reg_ptr(reg_0).unwrap()
                = self.reg_val(reg_0).unwrap() - self.reg_val(reg_1).unwrap();
        } else {
            *self.reg_ptr(reg_0).unwrap()
                = self.reg_val(reg_1).unwrap() - self.reg_val(reg_0).unwrap();
        }
    }

    // read: copy the value at a 16-bit memory address into a register.
    pub fn read(&mut self, reg: u8, address: u16, address_space: &Vec<u8>) {
        *self.reg_ptr(reg).unwrap() = combine_bytes(
            address_space[address as usize],
            address_space[(address + 1) as usize]
        );
    }

    // write: copy the value in a register into main memory.
    /* FIXME: both here and in the Python implementation, there's a bug where
    values larger than 255 can't be written to a memory address, even though those
    values are taken from 16-bit registers. Easiest fix would be NOTABUGWONTFIX,
    but probably not the best permanent solution. */
    pub fn write(&self, reg: u8, address: u16, address_space: &mut Vec<u8>) {
        address_space[address as usize] = self.reg_val(reg).unwrap() as u8;
    }

    // movr: copy the value of one register into another register.
    pub fn movr(&mut self, reg_0: u8, reg_1: u8) {
        *self.reg_ptr(reg_0).unwrap() = self.reg_val(reg_1).unwrap();
    }

    // movl: move a literal value into a register.
    pub fn movl(&mut self, reg: u8, value: u16) {
        *self.reg_ptr(reg).unwrap() = value;
    }

    // and: perform a bitwise AND operation on two registers.
    pub fn and(&mut self, reg_0: u8, reg_1: u8) {
        *self.reg_ptr(reg_0).unwrap() &= self.reg_val(reg_1).unwrap();
    }

    // or: perform a bitwise OR opeartion on two registers.
    pub fn or(&mut self, reg_0: u8, reg_1: u8) {
        *self.reg_ptr(reg_0).unwrap() |= self.reg_val(reg_1).unwrap();
    }

    // xor: perform a bitwise XOR operation on two registers.
    pub fn xor(&mut self, reg_0: u8, reg_1: u8) {
        *self.reg_ptr(reg_0).unwrap() ^= self.reg_val(reg_1).unwrap();
    }

    // not: perform a bitwise NOT operation on a register.
    pub fn not(&mut self, reg: u8) {
        let one_bsl_16 = ((1 << 16) - 1) as u16;
        *self.reg_ptr(reg).unwrap() = one_bsl_16 - self.reg_val(reg).unwrap();
    }

    /* Gotta say, Rust can get pretty verbose when you implement error handling... */

    // out: print a character to stdout.
    pub fn out(&mut self, reg: u8) {
        self.stdout.push(
            self.reg_val(reg).unwrap() as u8 as char // kinda hacky, fix later?
        );
    }

    // halt: end the program.
    pub fn halt(&self) {
        if self.ip < 0x10 {
            println!("Program terminated at address 0{:x?} with no errors", self.ip);
        } else {
            println!("Program terminated at address {:x?} with no errors", self.ip);
        }
    } // the VM is supposed to exit with code 0 immediately after this gets called

    // push: push a byte onto the stack.
    pub fn push(&mut self, reg: u8) {
        self.stack[self.stack_pointer as usize] = self.reg_val(reg).unwrap();
        if self.stack_pointer < 15 {
            self.stack_pointer += 1;
        } else {
            self.stack_flag = 1;
        }
    }

    // pop: pop a byte from the stack into a register.
    pub fn pop(&mut self, reg: u8) {
        if reg == 0x0E {
            self.ip = self.stack[self.stack_pointer as usize];
        } else {
            *self.reg_ptr(reg).unwrap() = self.stack[self.stack_pointer as usize];
        }

        if self.stack_pointer > 0 {
            self.stack_pointer -= 1;
        }
    }

    // ovrf: check the value of the stack flag to see if there's been an overflow.
    pub fn ovrf(&mut self, reg: u8) {
        *self.reg_ptr(reg).unwrap() = self.stack_flag as u16;
    }

    // clrovr: set the stack flag to zero.
    pub fn clrovr(&mut self) {
        self.stack_flag = 0;
    }

    // readr: read from a memory address stored in a register.
    pub fn readr(&mut self, reg_0: u8, reg_1: u8, address_space: &Vec<u8>) {
        self.read(reg_0, self.reg_val(reg_1).unwrap(), address_space);
    }

    // inc: increment a register.
    pub fn inc(&mut self, reg: u8) {
        *self.reg_ptr(reg).unwrap() += 1;
    }

    // dec: decrement a register.
    pub fn dec(&mut self, reg: u8) {
        *self.reg_ptr(reg).unwrap() -= 1;
    }

    // writr: write to a memory location specified by a register's value.
    pub fn writr(&self, reg_0: u8, reg_1: u8, address_space: &mut Vec<u8>) {
        self.write(reg_0, self.reg_val(reg_1).unwrap(), address_space);
    }

    // bsl: bitshift a register left by 1.
    pub fn bsl(&mut self, reg: u8) {
        *self.reg_ptr(reg).unwrap() <<= 1;
    }

    // bsr: bitshift a register right by 1.
    pub fn bsr(&mut self, reg: u8) {
        *self.reg_ptr(reg).unwrap() >>= 1;
    }
}
