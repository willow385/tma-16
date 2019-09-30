# IMPORTANT NOTE: this isn't finished yet
# version 0.0 of the disassembler

import sys

filename = ""
no_file = True
for arg in sys.argv:
    if arg[-4:] == ".tmx": # extension for TMA executables
        filename = arg
        no_file = False
if no_file:
    print("Error! No executable file loaded")

file_context = open(filename, "rb").read()
instructions = bytearray(file_context)

# This function takes two 8-bit bytes, interpreting the first as the
# most significant and the second as the least significant portions
# of a single 16-bit value.
def combine_bytes(byte_0, byte_1):
    byte_0_shifted = byte_0 << 8
    return byte_0_shifted | byte_1

def parse_reg_id(hex_val):
    if hex_val == 0x0A:
        return "ra"
    elif hex_val == 0x0B:
        return "rb"
    elif hex_val == 0x0C:
        return "rc"
    elif hex_val == 0x0D:
        return "rd"
    elif hex_val == 0x0E:
        return "ip"
    else:
        return f"; invalid regid {hex(hex_val)}"

i = 0
while i < len(instructions):
    if instructions[i] == 0x01:
        print("jmp " + hex(instructions[i + 1]) + hex(instructions[i + 2])[2:])
        i += 3
    elif instructions[i] == 0x02:
        print("jeq "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2]) + " "
              + hex(instructions[i + 3])
              + hex(instructions[i + 4])[2:]
        )
        i += 5
    elif instructions[i] == 0x03:
        print("jgr "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2]) + " "
              + hex(instructions[i + 3])
              + hex(instructions[i + 4])[2:]
        )
        i += 5
    elif instructions[i] == 0x04:
        print("add "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x05:
        print("sub "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x06:
        print("read "
              + parse_reg_id(instructions[i + 1]) + " "
              + hex(instructions[i + 2])
              + hex(instructions[i + 3])[2:]
        )
        i += 4
    elif instructions[i] == 0x07:
        print("write "
              + parse_reg_id(instructions[i + 1]) + " "
              + hex(instructions[i + 2])
              + hex(instructions[i + 3])[2:]
        )
        i += 4
    elif instructions[i] == 0x08:
        print("movr "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x09:
        print("movl "
              + parse_reg_id(instructions[i + 1]) + " "
              + hex(instructions[i + 2])
              + hex(instructions[i + 3])[2:]
        )
        i += 4
    elif instructions[i] == 0x0A:
        print("and "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x0B:
        print("or "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x0C:
        print("xor "
              + parse_reg_id(instructions[i + 1]) + " "
              + parse_reg_id(instructions[i + 2])
        )
        i += 3
    elif instructions[i] == 0x0D:
        print("not " + parse_reg_id(instructions[i + 1]))
        i += 2
    elif instructions[i] == 0x0E:
        print("out " + parse_reg_id(instructions[i + 1]))
        i += 2
    elif instructions[i] == 0x0F:
        print("halt")
        i += 1
    elif instructions[i] == 0x10:
        print("out " + parse_reg_id(instructions[i + 1]))
        i += 2
    else:
        print(f"pb {hex(combine_bytes(instructions[i], instructions[i+1]))}") # TODO: allow putting single bytes?
        i += 2
