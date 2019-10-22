#!/usr/bin/python3
# This is version 1.6 of the assembler

import sys
import re


# First we remove all the comments from the file
def strip_comments(line):
    if ";" in line:
        comment_token_index = line.index(";")
        return line[0:comment_token_index]
    else:
        return line


# expand the macros
def expand_macro_defs(token_list):
    for i in range(0, len(token_list)):
        try:
            if token_list[i] == "#define":
                macro_name = token_list[i + 1]
                macro_val = token_list[i + 2]
                for j in range(0, len(token_list)):
                    if token_list[j] == macro_name:
                        token_list[j] = macro_val
                token_list[i] = ""
                token_list[i + 1] = ""
                token_list[i + 2] = ""
        except IndexError:
            continue


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
    c = int(b, 2)
    return c


def least_sig_8_bits(val_16_bits):
    a = binary(val_16_bits)
    b = a[9:17]
    c = int(b, 2)
    return c


def is_int_literal(token):
    return re.match(r"^[0-9]+$", token)


def is_hex_literal(token):
    return re.match(r"^0x[0-9a-fA-F]+$", token)


def is_bin_literal(token):
    return re.match(r"^0b[0-1]+$", token)


def is_char_literal(token):
    return re.match(r"^'.'|'\\[nstr0]'$", token)


def is_chword_literal(token):
    return re.match(r'^".."|".\\[nstr0]"|"\\[nstr0]."|"\\[nstr0]\\[nstr0]"$', token)


def is_reg_literal(token):
    if token in ["ra", "rb", "rc", "rd", "ip"]:
        return True
    else:
        return False


def assemble(input_file, output_file=None):

    file_lines = open(input_file).read().split('\n')
    decommented_lines = []
    for line in file_lines:
        decommented_lines.append(strip_comments(line))

    # then we tokenize it
    tokens = []
    for line in decommented_lines:
        for token in line.split(' '):
            if token != '':
                tokens.append(token)

    expand_macro_defs(tokens)

    # then we turn it into TMA-16 machine code
    machine_code_bytes = []

    i = 0  # index of currently selected token
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

        elif is_char_literal(token):
            machine_code_bytes.append(0)
            if token[1] != '\\':
                machine_code_bytes.append(ord(token[1]))
            elif token[2] == 'n':
                machine_code_bytes.append(10)
            elif token[2] == 't':
                machine_code_bytes.append(11)
            elif token[2] == 'r':
                machine_code_bytes.append(13)
            elif token[2] == 's':
                machine_code_bytes.append(32)
            elif token[2] == '0':
                machine_code_bytes.append(0)
            else:
                machine_code_bytes.append(ord(token[3]))

        elif is_chword_literal(token):
            if token[1] != '\\':
                machine_code_bytes.append(ord(token[1]))
                if token[2] != '\\':
                    machine_code_bytes.append(ord(token[2]))
                elif token[3] == 'n':
                    machine_code_bytes.append(10)
                elif token[3] == 't':
                    machine_code_bytes.append(11)
                elif token[3] == 'r':
                    machine_code_bytes.append(13)
                elif token[3] == 's':
                    machine_code_bytes.append(32)
                elif token[3] == '0':
                    machine_code_bytes.append(0)
                else:
                    machine_code_bytes.append(ord(token[3]))
            elif token[2] == 'n':
                machine_code_bytes.append(10)
                if token[3] != '\\':
                    machine_code_bytes.append(ord(token[3]))
                elif token[4] == 'n':
                    machine_code_bytes.append(10)
                elif token[4] == 't':
                    machine_code_bytes.append(11)
                elif token[4] == 'r':
                    machine_code_bytes.append(13)
                elif token[4] == 's':
                    machine_code_bytes.append(32)
                elif token[4] == '0':
                    machine_code_bytes.append(0)
                else:
                    machine_code_bytes.append(ord(token[4]))
            elif token[2] == 't':
                machine_code_bytes.append(11)
                if token[3] != '\\':
                    machine_code_bytes.append(ord(token[3]))
                elif token[4] == 'n':
                    machine_code_bytes.append(10)
                elif token[4] == 't':
                    machine_code_bytes.append(11)
                elif token[4] == 'r':
                    machine_code_bytes.append(13)
                elif token[4] == 's':
                    machine_code_bytes.append(32)
                elif token[4] == '0':
                    machine_code_bytes.append(0)
                else:
                    machine_code_bytes.append(ord(token[4]))
            elif token[2] == 'r':
                machine_code_bytes.append(13)
                if token[3] != '\\':
                    machine_code_bytes.append(ord(token[3]))
                elif token[4] == 'n':
                    machine_code_bytes.append(10)
                elif token[4] == 't':
                    machine_code_bytes.append(11)
                elif token[4] == 'r':
                    machine_code_bytes.append(13)
                elif token[4] == 's':
                    machine_code_bytes.append(32)
                elif token[4] == '0':
                    machine_code_bytes.append(0)
                else:
                    machine_code_bytes.append(ord(token[4]))
            elif token[2] == 's':
                machine_code_bytes.append(32)
                if token[3] != '\\':
                    machine_code_bytes.append(ord(token[3]))
                elif token[4] == 'n':
                    machine_code_bytes.append(10)
                elif token[4] == 't':
                    machine_code_bytes.append(11)
                elif token[4] == 'r':
                    machine_code_bytes.append(13)
                elif token[4] == 's':
                    machine_code_bytes.append(32)
                else:
                    machine_code_bytes.append(ord(token[4]))
            else:
                machine_code_bytes.append(ord(token[2]))
                if token[3] != '\\':
                    machine_code_bytes.append(ord(token[3]))
                elif token[4] == 'n':
                    machine_code_bytes.append(10)
                elif token[4] == 't':
                    machine_code_bytes.append(11)
                elif token[4] == 'r':
                    machine_code_bytes.append(13)
                elif token[4] == 's':
                    machine_code_bytes.append(32)
                elif token[4] == '0':
                    machine_code_bytes.append(0)
                else:
                    machine_code_bytes.append(ord(token[4]))

        elif is_reg_literal(token):
            reg_token_to_bytes = {
                'ra': 0x0A,
                'rb': 0x0B,
                'rc': 0x0C,
                'rd': 0x0D,
                'ip': 0x0E,
            }
            reg_bytes = reg_token_to_bytes[token]
            machine_code_bytes.append(reg_bytes)

        elif token == "alloc":  # allocate (assembler directive to allocate a certain amount of memory)
            mem_amount = 0
            if is_int_literal(tokens[i + 1]):
                mem_amount = int(tokens[i + 1])
            elif is_hex_literal(tokens[i + 1]):
                mem_amount = int(tokens[i + 1], 16)
            elif is_bin_literal(tokens[i + 1]):
                mem_amount = int(tokens[i + 1][2:], 2)
            else:
                print(f"error: {input_file}: invalid literal `{tokens[i + 1]}`")
                exit(1)

            tokens[i + 1] = ""  # so we don't have a stray number in the code

            for i in range(0, mem_amount):
                machine_code_bytes.append(0x00)

        else:

            inst_token_to_byte = {
                'jmp': 0x01,     # unconditional jump
                'jeq': 0x02,     # jump-if-equal
                'jgr': 0x03,     # jump-if-greater
                'add': 0x04,
                'sub': 0x05,
                'read': 0x06,    # read from memory
                'write': 0x07,   # write to memory
                'movr': 0x08,    # move register
                'movl': 0x09,    # mov literal
                'and': 0x0A,
                'or': 0x0B,
                'xor': 0x0C,
                'not': 0x0D,
                'out': 0x0E,     # print to stdout
                'halt': 0x0F,
                'push': 0x10,
                'pop': 0x11,
                'ovrf': 0x12,    # check the stack overflow flag
                'clrovr': 0x13,  # clear the stack overflow flag
                'readr': 0x14,   # read from an address from a register
                'inc': 0x15,     # increment
                'dec': 0x16,     # increment
                'writr': 0x17,   # write to an address from a register
                'bsl': 0x18,    # bitshift left
                'bsr': 0x19,    # bitshift right
                'get': 0x20,     # get input
                'pb': None,     # put byte
                                 # (not an instruction, just an assembler directive to write a byte at that position)
            }

            try:
                byte_token = inst_token_to_byte[token]
            except KeyError:
                print(f"error: {input_file}: unrecognized operation `{token}` (at {i-1})")
                exit(1)

            if byte_token:
                machine_code_bytes.append(byte_token)

        i += 1  # update index counter

    # now create the executable
    new_file_name = output_file or input_file[:-4] + ".tmx"
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


def main():
    if len(sys.argv) < 2:
        print("Error! No assembly files input")
        print(f"usage: python3 {sys.argv[0]} [assembly file]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) == 3 else None
    assemble(input_file, output_file)


if __name__ == '__main__':
    main()
