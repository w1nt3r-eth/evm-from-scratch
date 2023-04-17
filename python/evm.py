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
import os
from typing import Tuple, List

def evm(code: bytes) -> Tuple[bool, List[str]]:
    pc = 0
    success = True
    stack = []

    while pc < len(code):
        op = code[pc]
        pc += 1

        # TODO: implement the EVM here!
        

    return (success, stack)

def test():
    script_dirname = os.path.dirname(os.path.abspath(__file__))
    json_file = os.path.join(script_dirname, "..", "evm.json")
    with open(json_file) as f:
        data = json.load(f)
        total = len(data)

        for i, test in enumerate(data):
            # Note: as the test cases get more complex, you'll need to modify this
            # to pass down more arguments to the evm function
            code = bytes.fromhex(test['code']['bin'])
            (success, stack) = evm(code)

            expected_stack = [int(x, 16) for x in test['expect']['stack']]
            
            if stack != expected_stack or success != test['expect']['success']:
                print(f"❌ Test #{i + 1}/{total} {test['name']}")
                if stack != expected_stack:
                    print("Stack doesn't match")
                    print(f"\tExpected:\t{expected_stack}")
                    print(f"\tActual:\t\t{stack}")
                else:
                    print("Success doesn't match")
                    print(f"\tExpected:\t{test['expect']['success']}")
                    print(f"\tActual:\t\t{success}")
                print("\nTest code:")
                print(test['code']['asm'])
                print("\nHint:", test['hint'])
                print(f"\nProgress: {i}/{len(data)}\n")
                break
            else:
                print(f"✓  Test #{i + 1}/{total} {test['name']}")

if __name__ == '__main__':
    test()
