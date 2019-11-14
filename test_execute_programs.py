"""
    Program to test the TMA-16 Assembler with pytest.
    Written by Romain Pesche.
"""

import re
import subprocess
import tempfile
from pathlib import Path
import pytest
import os

from tma_16_assembler import assemble


@pytest.fixture(autouse=True, scope="function")
def check_vm_executable():
    vm_location = Path('tma-16-rs/target/debug/tma-16-rs')
    if not vm_location.exists():
        pytest.skip("No rust VM available, please run :  cd tma-16-rs && cargo build")


def launch_asm(source_file):

    output_file = tempfile.NamedTemporaryFile(suffix=".tmx")

    os.system("cd programs")

    assemble(source_file, output_file.name)

    res = subprocess.run([
        'tma-16-rs/target/debug/tma-16-rs',
        output_file.name,
        '--no-display',
        '--report'], capture_output=True)
    assert res

    stdout = res.stdout.decode('utf-8')
    stderr = res.stderr.decode('utf-8')

    os.system("cd ..")

    return stdout, stderr


@pytest.mark.parametrize("source_file, result", [
    ('programs/helloworld.asm', ('Hello, world!', 'FD', '10C', '0', '0', '0', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
    ('programs/bitshift.asm', ('', '1C', '1111', '40', '40', '0', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
    ('programs/divide.asm', ('0x1776 divided by 0x0004 equals 0x05DD, remainder 0x0002',
                             '1F0', 'A', '1', '0', 'EC', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
    ('programs/e.asm', ('E', '06', '45', '0', '0', '0', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
    ('programs/mult.asm', ('DONE', '41', '15', '1', '3', 'A', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
    ('programs/str_print.asm', ('This program was written in TMA-16 Assembly by Dante Falzone',
                                'FD', '13B', '0', '0', '0', '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0')),
])
def test_program_execution(source_file, result):

    report_string, error_string = launch_asm(source_file)
    assert not error_string

    regex = re.compile(r"""
        (.*)\n?
        Program\ terminated\ at\ address\ ([\dA-F]+)\ with\ no\ errors\n
        RA:\ (.*)\n
        RB:\ (.*)\n
        RC:\ (.*)\n
        RD:\ (.*)\n
        Stack:\ (.*)
    """, re.VERBOSE | re.MULTILINE)

    match = re.match(regex, report_string)

    assert match
    assert match.groups() == result


@pytest.mark.parametrize("source_file, thread, error", [
    ("programs/except.asm", 'main', 'attempt to add with overflow'),
])
def test_program_with_exception(source_file, thread, error):

    report_string, error_string = launch_asm(source_file)
    assert not report_string.replace('\n', '')

    match = re.match(r"thread '(.*)' panicked at '(.*)',", error_string)

    assert match.groups() == (thread, error)
