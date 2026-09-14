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


def evm(code: bytes) -> dict:
    pc = 0
    success = True
    stack: list[int] = []

    while pc < len(code):
        op = code[pc]
        pc += 1

        # TODO: implement the EVM here!

    return {"success": success, "stack": stack, "return": "", "logs": [], "state": {}}


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
        result = evm(code)
        mismatches = []
        for field, expected in test['expect'].items():
            if expected is None:
                continue
            if field == 'stack':
                expected = [int(x, 16) for x in expected]
            if result.get(field) != expected:
                mismatches.append((field, expected, result.get(field)))

        if mismatches:
            print(f"❌ Test #{i + 1}/{total} {test['name']}")
            for field, expected, actual in mismatches:
                print(f"{field} doesn't match")
                print(" expected:", expected)
                print("   actual:", actual)
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
