# This is version 1.1 of the TMA-16

import sys
import time

# This function gets called if something gets fucked up, providing
# an informative error message so either the VM implementation or
# the program can be debugged.
def hardware_exception(error_msg, machine):
    print(f"Error! {error_msg}")
    print("TMA-16 core dumped")
    sys.exit(1)


# This function performs a bitwise NOT operation, because for some dumb
# stupid reason, Python doesn't have such a capability built in.
def bitwise_not(num):
    return (1 << 16) - 1 - num

# This function takes two 8-bit bytes, interpreting the first as the
# most significant and the second as the least significant portions
# of a single 16-bit value.
def combine_bytes(byte_0, byte_1):
    byte_0_shifted = byte_0 << 8
    return byte_0_shifted | byte_1

# This function returns the indexth bit of a 16-bit value, triggering
# a hardware exception if a number greater than 65535 is passed.
def byte_index(index, byte, machine):
    if index > 15 or index < 0:
        print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        hardware_exception("Values can only have 16 bits", machine)
    if byte >= (2 ** 16) or byte < 0:
        print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        hardware_exception("Values cannot be greater than 0xFFFF", machine)
    byte_string = format(byte, "#018b")[2:]
    return byte_string[(-1 * index) - 1]

# Considering the fact that there's not likely to be multiple TMA-16s
# in the same process at the same time, there wasn't a good reason for this
# to be a class, but here it is anyway.
class TMA_16:
    def __init__(self):
        # General-purpose registers
        self.ra = 0
        self.rb = 0
        self.rc = 0
        self.rd = 0

        # Instruction pointer
        self.ip = 0

        # Stack (yes, it's only 16 bytes)
        self.stack = [0] * 16
        self.stack_pointer = 0

        # Stack flag: set to 1 in the event of a stack overflow
        self.stack_flag = 0

        self.current_instruction = 0
        self.stdout = ""
        self.line_height = 24

    # This function takes a number between 0x0A and 0x0E and returns the
    # value in the register corresponding to that number.
    def reg_val(self, num):
        if num == 0x0A:
            return self.ra
        elif num == 0x0B:
            return self.rb
        elif num == 0x0C:
            return self.rc
        elif num == 0x0D:
            return self.rd
        elif num == 0x0E:
            return self.ip
        else:
            hardware_exception(f"nonexistent register ``r{hex(num)[2:]}''", self)

    # A very long, very badly-written function that really ought to be broken up and modularized
    # if I ever get around to refactoring this. This function takes a program in the form of a
    # bytearray and executes the instruction selected by the instruction pointer.
    def execute(self, program):
        try:
            self.current_instruction = program[self.ip]
        except IndexError:
            hardware_exception(f"segmentation fault (process attempted to access illegal address {hex(self.ip)})", self)

        if program[self.ip] == 0x01: # jmp: unconditional jump instruction
            self.ip = combine_bytes(program[self.ip + 1], program[self.ip + 2])

        elif program[self.ip] == 0x02: # jeq: jump to address if first register equals second
            if self.reg_val(program[self.ip + 1]) == self.reg_val(program[self.ip + 2]):
                self.ip = combine_bytes(program[self.ip + 3], program[self.ip + 4])
            else:
                self.ip += 5

        elif program[self.ip] == 0x03: # jgr: jump to address if first register > second
            if self.reg_val(program[self.ip + 1]) > self.reg_val(program[self.ip + 2]):
                self.ip = combine_bytes(program[self.ip + 3], program[self.ip + 4])
            else:
                self.ip += 5

        elif program[self.ip] == 0x04: # add: store the sum of two registers in the first register
            if program[self.ip + 1] == 0x0A:
                self.ra += self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0B:
                self.rb += self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0C:
                self.rc += self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0D:
                self.rd += self.reg_val(program[self.ip + 2])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x05: # sub: store absolute value of difference of two regs in first reg
            if program[self.ip + 1] == 0x0A:
                self.ra -= self.reg_val(program[self.ip + 2])
                if self.ra < 0:
                    self.ra *= -1
            elif program[self.ip + 1] == 0x0B:
                self.rb -= self.reg_val(program[self.ip + 2])
                if self.rb < 0:
                    self.rb *= -1
            elif program[self.ip + 1] == 0x0C:
                self.rc -= self.reg_val(program[self.ip + 2])
                if self.rc < 0:
                    self.rc *= -1
            elif program[self.ip + 1] == 0x0D:
                self.rd -= self.reg_val(program[self.ip + 2])
                if self.rd < 0:
                    self.rd *= -1
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x06: # read: read a byte from a 16-bit address in memory
            value = program[combine_bytes(program[self.ip + 2], program[self.ip + 3])]
            if len(program) < value:
                hardware_exception(f"segmentation fault 0x06 - unable to access memory address {hex(value)}", self)

            if program[self.ip + 1] == 0x0A:
                self.ra = value
            elif program[self.ip + 1] == 0x0B:
                self.rb = value
            elif program[self.ip + 1] == 0x0C:
                self.rc = value
            elif program[self.ip + 1] == 0x0D:
                self.rd = value
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 4

        elif program[self.ip] == 0x07: # write: write a byte to a 16-bit address in memory
            dest = combine_bytes(program[self.ip + 2], program[self.ip + 3])
            if len(program) < dest:
                hardware_exception(f"segmentation fault 0x07 - unable to access memory address {hex(dest)}", self)

            if program[self.ip + 1] == 0x0A:
                program[dest] = self.ra
            elif program[self.ip + 1] == 0x0B:
                program[dest] = self.rb
            elif program[self.ip + 1] == 0x0C:
                program[dest] = self.rc
            elif program[self.ip + 1] == 0x0D:
                program[dest] = self.rd
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 4

        elif program[self.ip] == 0x08: # movr: copy one register into another
            if program[self.ip + 1] == 0x0A:
                self.ra = self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0B:
                self.rb = self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0C:
                self.rc = self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0D:
                self.rd = self.reg_val(program[self.ip + 2])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x09: # movl: move a literal value into a register
            if program[self.ip + 1] == 0x0A:
                self.ra = combine_bytes(program[self.ip + 2], program[self.ip + 3])
            elif program[self.ip + 1] == 0x0B:
                self.rb = combine_bytes(program[self.ip + 2], program[self.ip + 3])
            elif program[self.ip + 1] == 0x0C:
                self.rc = combine_bytes(program[self.ip + 2], program[self.ip + 3])
            elif program[self.ip + 1] == 0x0D:
                self.rd = combine_bytes(program[self.ip + 2], program[self.ip + 3])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 4

        elif program[self.ip] == 0x0A: # and: perform bitwise AND on two registers
            if program[self.ip + 1] == 0x0A:
                self.ra &= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0B:
                self.rb &= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0C:
                self.rc &= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0D:
                self.rd &= self.reg_val(program[self.ip + 2])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x0B: # or: perform bitwise OR on two registers
            if program[self.ip + 1] == 0x0A:
                self.ra |= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0B:
                self.rb |= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0C:
                self.rc |= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0D:
                self.rd |= self.reg_val(program[self.ip + 2])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x0C: # xor: perform bitwise XOR on two registers
            if program[self.ip + 1] == 0x0A:
                self.ra ^= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0B:
                self.rb ^= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0C:
                self.rc ^= self.reg_val(program[self.ip + 2])
            elif program[self.ip + 1] == 0x0D:
                self.rd ^= self.reg_val(program[self.ip + 2])
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x0D: # not: perform bitwise NOT on a register
            if program[self.ip + 1] == 0x0A:
                self.ra = bitwise_not(self.ra)
            elif program[self.ip + 1] == 0x0B:
                self.rb = bitwise_not(self.rb)
            elif program[self.ip + 1] == 0x0C:
                self.rc = bitwise_not(self.rc)
            elif program[self.ip + 1] == 0x0D:
                self.rd = bitwise_not(self.rd)
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 2


        elif program[self.ip] == 0x0E: # out: print to stdout
            self.stdout += chr(self.reg_val(program[self.ip + 1]))
            if self.reg_val(program[self.ip + 1]) == 10: # newline
                self.reset_screen()
                self.line_height += 1
                self.display_internals()
            self.ip += 2

        elif program[self.ip] == 0x0F: # halt: stop running
            print(f"\nProgram terminated at address {hex(self.ip)} with no errors")
            sys.exit(0)

        elif program[self.ip] == 0x10: # push: push a byte onto the stack
            self.stack[self.stack_pointer] = self.reg_val(program[self.ip + 1])
            if self.stack_pointer < 15:
                self.stack_pointer += 1
            else:
                self.stack_flag = 1
            self.ip += 2

        elif program[self.ip] == 0x11: # pop: take a byte off the stack
            ip_manip = False # flag to tell if we're directly manipulating the instruction pointer
            if program[self.ip + 1] == 0x0A:
                self.ra = self.stack[self.stack_pointer]
            elif program[self.ip + 1] == 0x0B:
                self.rb = self.stack[self.stack_pointer]
            elif program[self.ip + 1] == 0x0C:
                self.rc = self.stack[self.stack_pointer]
            elif program[self.ip + 1] == 0x0D:
                self.rd = self.stack[self.stack_pointer]
            elif program[self.ip + 1] == 0x0E:
                ip_manip = True
                self.ip = self.stack[self.stack_pointer]
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.stack[self.stack_pointer] = 0x00 # the value is now gone from the stack
            if self.stack_pointer > 0:
                self.stack_pointer -= 1
            if self.stack_pointer < 0:
                hardware_exception(f"implementation bug triggered at address {hex(self.ip)} (attempted to access negative stack index)", self)
            if not ip_manip:
                self.ip += 2

        elif program[self.ip] == 0x12: # ovrf: check the stack flag, presumably to see if there's an overflow
            if program[self.ip + 1] == 0x0A:
                self.ra = self.stack_flag
            elif program[self.ip + 1] == 0x0B:
                self.rb = self.stack_flag
            elif program[self.ip + 1] == 0x0C:
                self.rc = self.stack_flag
            elif program[self.ip + 1] == 0x0D:
                self.rd = self.stack_flag
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 2

        elif program[self.ip] == 0x13: # clrovr: reset the stack flag to 0
            self.stack_flag = 0
            self.ip += 1

        elif program[self.ip] == 0x14: # readr: read from a memory address stored in a register
            if program[self.ip + 1] == 0x0A:
                self.ra = program[self.reg_val(program[self.ip + 2])]
            elif program[self.ip + 1] == 0x0B:
                self.rb = program[self.reg_val(program[self.ip + 2])]
            elif program[self.ip + 1] == 0x0C:
                self.rc = program[self.reg_val(program[self.ip + 2])]
            elif program[self.ip + 1] == 0x0D:
                self.rd = program[self.reg_val(program[self.ip + 2])]
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 3

        elif program[self.ip] == 0x15: # inc: increment a register
            overflow_flag = False
            if program[self.ip + 1] == 0x0A:
                if self.ra < 0xFFFF:
                    self.ra += 1
                else:
                    overflow_flag = True
            elif program[self.ip + 1] == 0x0B:
                if self.rb < 0xFFFF:
                    self.rb += 1
                else:
                    overflow_flag = True
            elif program[self.ip + 1] == 0x0C:
                if self.rc < 0xFFFF:
                    self.rc += 1
                else:
                    overflow_flag = True
            elif program[self.ip + 1] == 0x0D:
                if self.rd < 0xFFFF:
                    self.rd += 1
                else:
                    overflow_flag = True
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            if overflow_flag:
                hardware_exception(f"value too large for 16-bit unsigned integer, triggered at address {hex(self.ip)}", self)
            self.ip += 2

        elif program[self.ip] == 0x16: # dec: decrement a register
            if program[self.ip + 1] == 0x0A:
                if self.ra > 0:
                    self.ra -= 1
            elif program[self.ip + 1] == 0x0B:
                if self.rb > 0:
                    self.rb -= 1
            elif program[self.ip + 1] == 0x0C:
                if self.rc > 0:
                    self.rc -= 1
            elif program[self.ip + 1] == 0x0D:
                if self.rd > 0:
                    self.rd -= 1
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 2

        elif program[self.ip] == 0x17: # writr: write to a register-specified memory address
            if program[self.ip + 1] == 0x0A:
                program[self.reg_val(program[self.ip + 2])] = self.ra 
            elif program[self.ip + 1] == 0x0B:
                program[self.reg_val(program[self.ip + 2])] = self.rb
            elif program[self.ip + 1] == 0x0C:
                program[self.reg_val(program[self.ip + 2])] = self.rc
            elif program[self.ip + 1] == 0x0D:
                program[self.reg_val(program[self.ip + 2])] = self.rd 
            else:
                hardware_exception(f"illegal instruction at address {hex(self.ip)}", self)
            self.ip += 4

        else:
            hardware_exception(f"unknown/unimplemeted instruction ``{hex(program[self.ip])}'' at address {hex(self.ip)}", self)


    # This function prints a diagram showing the state of the TMA-16's internals. It uses fancy
    # box-drawing characters by default, or the characters +-| if the option "-p" or "--poor" is
    # passed in the command line.
    def display_internals(self):
        if "-p" in sys.argv or "--poor" in sys.argv: # option to print with pure ascii chars only
            print("   Registers:")
            print("                Binary                Hex")
            print("   +" + ("-+" * 15) + "-+ +----+")
            print("RA |", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.ra, self) + "|", end="")
            if self.ra < 0x10:
                print(" |000%X|" % self.ra, end="")
            elif self.ra < 0x100:
                print(" |00%X|" % self.ra, end="")
            elif self.ra < 0x1000:
                print(" |0%X|" % self.ra, end="")
            else:
                print(" |%X|" % self.ra, end="")
            print("")
            print("   +" + ("-+" * 15) + "-+ +----+")
            print("RB |", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rb, self) + "|", end="")
            if self.rb < 0x10:
                print(" |000%X|" % self.rb, end="")
            elif self.rb < 0x100:
                print(" |00%X|" % self.rb, end="")
            elif self.rb < 0x1000:
                print(" |0%X|" % self.rb, end="")
            else:
                print(" |%X|" % self.rb, end="")
            print("")
            print("   +" + ("-+" * 15) + "-+ +----+")
            print("RC |", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rc, self) + "|", end="")
            if self.rc < 0x10:
                print(" |000%X|" % self.rc, end="")
            elif self.rc < 0x100:
                print(" |00%X|" % self.rc, end="")
            elif self.rc < 0x1000:
                print(" |0%X|" % self.rc, end="")
            else:
                print(" |%X|" % self.rc, end="")
            print("")
            print("   +" + ("-+" * 15) + "-+ +----+")
            print("RD |", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rd, self) + "|", end="")
            if self.rd < 0x10:
                print(" |000%X|" % self.rd, end="")
            elif self.rd < 0x100:
                print(" |00%X|" % self.rd, end="")
            elif self.rd < 0x1000:
                print(" |0%X|" % self.rd, end="")
            else:
                print(" |%X|" % self.rd, end="")
            print("")
            print("   +" + ("-+" * 15) + "-+ +----+")
            print("")
            print("Stack:")
            print("+" + ("----+" * 15) + "----+")
            print("|", end="")
            for byte in self.stack:
                if byte < 0x10:
                    print("000%X" % byte, end="|")
                elif byte < 0x100:
                    print("00%X" % byte, end="|")
                elif byte < 0x1000:
                    print("0%X" % byte, end="|")
                else:
                    print("%X" % byte, end="|")
            if self.stack_flag == 1:
                print(" STACK OVERFLOW", end="")
            else:
                print("               ", end="")
            print("\n+" + ("----+" * 15) + "----+")
            print("")
            print("                    +----+")
            if self.ip < 0x10:
                print("Instruction Pointer |000%X|" % self.ip)
            elif self.ip < 0x100:
                print("Instruction Pointer |00%X|" % self.ip)
            elif self.ip < 0x1000:
                print("Instruction Pointer |0%X|" % self.ip)
            else:
                print("Instruction Pointer |%X|" % self.ip)
            print("                    +----+")
            if self.current_instruction < 0x10:
                print("Current Instruction | 0%X |" % self.current_instruction)
            else:
                print("Current Instruction | %X |" % self.current_instruction)
            print("                    +----+")
            print("Stdout:")
            print(self.stdout, end="")
            print("")
        else:
            print("   Registers:")
            print("                Binary                Hex")
            print("   ╔" + ("═╦" * 15) + "═╗ ╔════╗")
            print("RA ║", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.ra, self) + "║", end="")
            if self.ra < 0x10:
                print(" ║000%X║" % self.ra, end="")
            elif self.ra < 0x100:
                print(" ║00%X║" % self.ra, end="")
            elif self.ra < 0x1000:
                print(" ║0%X║" % self.ra, end="")
            else:
                print(" ║%X║" % self.ra, end="")
            print("")
            print("   ╠" + ("═╬" * 15) + "═╣ ╠════╣")
            print("RB ║", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rb, self) + "║", end="")
            if self.rb < 0x10:
                print(" ║000%X║" % self.rb, end="")
            elif self.rb < 0x100:
                print(" ║00%X║" % self.rb, end="")
            elif self.rb < 0x1000:
                print(" ║0%X║" % self.rb, end="")
            else:
                print(" ║%X║" % self.rb, end="")
            print("")
            print("   ╠" + ("═╬" * 15) + "═╣ ╠════╣")
            print("RC ║", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rc, self) + "║", end="")
            if self.rc < 0x10:
                print(" ║000%X║" % self.rc, end="")
            elif self.rc < 0x100:
                print(" ║00%X║" % self.rc, end="")
            elif self.rc < 0x1000:
                print(" ║0%X║" % self.rc, end="")
            else:
                print(" ║%X║" % self.rc, end="")
            print("")
            print("   ╠" + ("═╬" * 15) + "═╣ ╠════╣")
            print("RD ║", end="")
            for i in range (15, -1, -1):
                print(byte_index(i, self.rd, self) + "║", end="")
            if self.rd < 0x10:
                print(" ║000%X║" % self.rd, end="")
            elif self.rd < 0x100:
                print(" ║00%X║" % self.rd, end="")
            elif self.rd < 0x1000:
                print(" ║0%X║" % self.rd, end="")
            else:
                print(" ║%X║" % self.rd, end="")
            print("")
            print("   ╚" + ("═╩" * 15) + "═╝ ╚════╝")
            print("")
            print("Stack:")
            print("╔" + ("════╦" * 15) + "════╗")
            print("║", end="")
            for byte in self.stack:
                if byte < 0x10:
                    print("000%X" % byte, end="║")
                elif byte < 0x100:
                    print("00%X" % byte, end="║")
                elif byte < 0x1000:
                    print("0%X" % byte, end="║")
                else:
                    print("%X" % byte, end="║")
            if self.stack_flag == 1:
                print(" STACK OVERFLOW", end="")
            else:
                print("               ", end="") # overwrite the words "STACK OVERFLOW" if they've been written
            print("\n╚" + ("════╩" * 15) + "════╝")
            print("")
            print("                    ╔════╗")
            if self.ip < 0x10:
                print("Instruction Pointer ║000%X║" % self.ip)
            elif self.ip < 0x100:
                print("Instruction Pointer ║00%X║" % self.ip)
            elif self.ip < 0x1000:
                print("Instruction Pointer ║0%X║" % self.ip)
            else:
                print("Instruction Pointer ║%X║" % self.ip)
            print("                    ╠════╣")
            if self.current_instruction < 0x10:
                print("Current Instruction ║ 0%X ║" % self.current_instruction)
            else:
                print("Current Instruction ║ %X ║" % self.current_instruction)
            print("                    ╚════╝")
            print("Stdout:")
            print(self.stdout, end="")
            print("")

    # Function to move the cursor up to where the diagram of the internals was printed from.
    def reset_screen(self):
        for i in range (0, self.line_height):
            print("\x1b[A", end="")


machine = TMA_16()
machine.display_internals()

filename = ""
no_file = True
for arg in sys.argv:
    if arg[-4:] == ".tmx": # extension for TMA executables
        filename = arg
        no_file = False
if no_file:
    hardware_exception("no program loaded", machine)

file_context = open(filename, "rb").read()
instructions = bytearray(file_context)

while True:
    time.sleep(0.2) # TODO: make this a command-line option instead of hardcoding it
    machine.reset_screen()
    machine.display_internals()
    machine.execute(instructions)
