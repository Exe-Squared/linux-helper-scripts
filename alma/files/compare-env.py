#!/usr/bin/env python3

import sys


class Colours:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    RED = '\033[91m'


def parse_env(file_path):
    variables = set()

    with open(file_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                var = line.split('=', 1)[0].strip()
                variables.add(var)

    return variables


def usage():
    print(f"""
    Usage {sys.argv[0]} file1 file2
    This will determine env varaible defined in file1 but not file2, and vice versa
    """)


def coloured(text, colour):
    return f"{colour}{text}\033[0m"


if len(sys.argv) != 3:
    # script file1 file2
    usage()
    quit(1)

file1 = sys.argv[1]
file2 = sys.argv[2]

file1_vars = parse_env(file1)
file2_vars = parse_env(file2)

in1ButNot2 = file1_vars - file2_vars
in2ButNot1 = file2_vars - file1_vars

for var in in1ButNot2:
    print(f"Variable {coloured(var, Colours.BLUE)} is in {coloured(file1, Colours.GREEN)} but not {coloured(file2, Colours.RED)}")

print("\n" * 2)

for var in in2ButNot1:
    print(f"Variable {coloured(var, Colours.BLUE)} is in {coloured(file2, Colours.GREEN)} but not {coloured(file1, Colours.RED)}")


