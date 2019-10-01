# TODO: add macros and make it so that you can jump to a location without having to know its exact address

# UPDATE 30 September 2019: this assembler now supports "#define", allowing you to create global constants
# in your assembly programs.

# This is version 1.0 of the assembler

# edited for Windows compatibility

import sys
import re

filex = ""
if len(sys.argv) < 2:
    filex = input("Enter filename: ")
else:
    filex = sys.argv[1]

file_lines = open(filex).read().split('\n')

# First we remove all the comments from the file
def strip_comments(line):
    if ";" in line:
        comment_token_index = line.index(";")
        return line[0:comment_token_index]
    else:
        return line

decommented_lines = []
for line in file_lines:
    decommented_lines.append(strip_comments(line))

# then we tokenize it
tokens = []
for line in decommented_lines:
    for token in line.split(' '):
        if token != '':
            tokens.append(token)

# expand the macros
def expand_macro_defs(token_list):
    for i in range (0, len(token_list)):
        try:
            if token_list[i] == "#define":
                macro_name = token_list[i + 1]
                macro_val  = token_list[i + 2]
                for j in range (0, len(token_list)):
                    if token_list[j] == macro_name:
                        token_list[j] = macro_val
                token_list[i] = ""
                token_list[i + 1] = ""
                token_list[i + 2] = ""
        except IndexError:
            continue

expand_macro_defs(tokens)

# then we turn it into TMA-16 machine code
machine_code_bytes = []

def is_int_literal(token):
    return re.match(r"^[0-9]+$", token)
def is_hex_literal(token):
    return re.match(r"^0x[0-9a-fA-F]+$", token)
def is_bin_literal(token):
    return re.match(r"^0b[0-1]+$", token)
def is_reg_literal(token):
    if token in ["ra", "rb", "rc", "rd", "ip"]:
        return True
    else:
        return False

# this part is mostly copied from Stack Overflow
# https://stackoverflow.com/questions/32834963/most-significant-byte-calculation
def binary(i):
    if i == 0:
        return "0000000000000000"
    s = ''
    count = 17
    while count:
        if i & 1 == 1:
            s = "1" + s
        else:
            s = "0" + s
        i >>= 1
        count -= 1
    return s
def most_sig_8_bits(val_16_bits):
    a = binary(val_16_bits)
    b = a[0:9]
    c = int(b,2)
    return c
def least_sig_8_bits(val_16_bits):
    a = binary(val_16_bits)
    b = a[9:17]
    c = int(b,2)
    return c

for token in tokens:
    # The instruction set of the TMA-16 is based on a
    # pen-and-paper model I made earlier called the TMA-8. I
    # chose to make the digital version 16-bit so it could
    # address enough instructions to do non-trivial programs.
    # However, the architecture still expects executables to be
    # composed of 8-bit bytes. Because of this, integer literals
    # have to be stored in two bytes: the most and least
    # significant 8 bits. This is more efficient than my other
    # two options, which are to prefix all instructions with
    # enough padding to make everything 16 bits, or to create a
    # brand-new instruction set again.
    if token == "":
        continue

    elif is_int_literal(token):
        machine_code_bytes.append(most_sig_8_bits(int(token)))
        machine_code_bytes.append(least_sig_8_bits(int(token)))

    elif is_hex_literal(token):
        machine_code_bytes.append(most_sig_8_bits(int(token, 16)))
        machine_code_bytes.append(least_sig_8_bits(int(token, 16)))

    elif is_bin_literal(token):
        machine_code_bytes.append(most_sig_8_bits(int(token[2:], 2)))
        machine_code_bytes.append(least_sig_8_bits(int(token[2:], 2)))

    elif is_reg_literal(token):
        if token == "ra":
            machine_code_bytes.append(0x0A)

        elif token == "rb":
            machine_code_bytes.append(0x0B)

        elif token == "rc":
            machine_code_bytes.append(0x0C)

        elif token == "rd":
            machine_code_bytes.append(0x0D)

        elif token == "ip":
            machine_code_bytes.append(0x0E)

    elif token == "jmp": # unconditional jump
        machine_code_bytes.append(0x01)

    elif token == "jeq": # jump-if-equal
        machine_code_bytes.append(0x02)

    elif token == "jgr": # jump-if-greater
        machine_code_bytes.append(0x03)

    elif token == "add":
        machine_code_bytes.append(0x04)

    elif token == "sub":
        machine_code_bytes.append(0x05)

    elif token == "read": # read from memory
        machine_code_bytes.append(0x06)

    elif token == "write": # write to memory
        machine_code_bytes.append(0x07)

    elif token == "movr": # move register
        machine_code_bytes.append(0x08)

    elif token == "movl": # move literal
        machine_code_bytes.append(0x09)

    elif token == "and":
        machine_code_bytes.append(0x0A)

    elif token == "or":
        machine_code_bytes.append(0x0B)

    elif token == "xor":
        machine_code_bytes.append(0x0C)

    elif token == "not":
        machine_code_bytes.append(0x0D)

    elif token == "out": # print to stdout
        machine_code_bytes.append(0x0E)

    elif token == "halt":
        machine_code_bytes.append(0x0F) # the actual opcode
        machine_code_bytes.append(0x48) # H
        machine_code_bytes.append(0x41) # A
        machine_code_bytes.append(0x4C) # L
        machine_code_bytes.append(0x54) # T

    elif token == "push":
        machine_code_bytes.append(0x10)

    elif token == "pop":
        machine_code_bytes.append(0x11)

    elif token == "ovrf": # check the stack overflow flag
        machine_code_bytes.append(0x12)

    elif token == "clrovr": # clear the stack overflow flag
        machine_code_bytes.append(0x13)

    elif token == "readr": # read from an address from a register
        machine_code_bytes.append(0x14)

    elif token == "inc": # increment
        machine_code_bytes.append(0x15)

    elif token == "dec": # decrement
        machine_code_bytes.append(0x16)

    elif token == "writr": #write to an address from a register
        machine_code_bytes.append(0x17)

    elif token == "pb": # put byte (not an instruction, just an assembler directive to write a byte at that position)
        pass

    else:
        print(f"error: {sys.argv[1]}: unrecognized operation `{token}`")
        exit(1)


# now create the executable
new_file_name = filex[:-4] + ".tmx"
new_file = open(new_file_name, "w+b")
binary_format = bytearray(machine_code_bytes)
new_file.write(binary_format)
new_file.close()

line_bytes = 0
if "-h" in sys.argv or "--hexdump" in sys.argv:
    for byte in machine_code_bytes:
        if byte < 0x10:
            print("0" + hex(byte)[2:], end=" ")
        else:
            print(hex(byte)[2:], end=" ")
        if line_bytes == 7:
            print("")
            line_bytes = 0
        else:
            line_bytes += 1
    print("")
