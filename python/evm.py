#!/usr/bin/env python3

# EVM From Scratch
# Python template
#
# To work on EVM From Scratch in Python:
#
# - Install Python3: https://www.python.org/downloads/
# - Go to the `python` directory: `cd python`
# - Edit `evm.py` (this file!), see TODO below
# - Run `python3 evm.py` to run the tests

import json
from pathlib import Path


def evm(code: bytes) -> tuple[bool, list[int]]:
    pc = 0
    success = True
    stack: list[int] = []

    while pc < len(code):
        op = code[pc]
        pc += 1

        # TODO: implement the EVM here!

    return success, stack


def test():
    root = Path(__file__).resolve().parent.parent
    json_file = root / "evm-pro.json"
    if not json_file.exists():
        json_file = root / "evm.json"
    with json_file.open(encoding="utf-8") as f:
        data = json.load(f)
    total = len(data)

    for i, test in enumerate(data):
        # Note: as the test cases get more complex, you'll need to modify this
        # to pass down more arguments to the evm function
        code = bytes.fromhex(test['code']['bin'])
        success, stack = evm(code)

        expected_stack = test['expect'].get('stack')
        if expected_stack is not None:
            expected_stack = [int(x, 16) for x in expected_stack]
        stack_matches = expected_stack is None or stack == expected_stack

        if not stack_matches or success != test['expect']['success']:
            print(f"❌ Test #{i + 1}/{total} {test['name']}")
            if not stack_matches:
                print("Stack doesn't match")
                print(" expected:", expected_stack)
                print("   actual:", stack)
            else:
                print("Success doesn't match")
                print(" expected:", test['expect']['success'])
                print("   actual:", success)
            print("")
            print("Test code:")
            print(test['code']['asm'] or test['code']['bin'])
            print("")
            print("Hint:", test['hint'])
            print("")
            print(f"Progress: {i}/{len(data)}")
            print("")
            raise SystemExit(1)
        else:
            print(f"✓  Test #{i + 1}/{total} {test['name']}")


if __name__ == '__main__':
    test()
