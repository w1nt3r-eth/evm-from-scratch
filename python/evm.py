#!/usr/bin/env python3
import json

def evm(code):
    pass

def test():
    with open('../evm.json') as f:
        data = json.load(f)
        total = len(data)

        for i, test in enumerate(data):
            print("Test #" + str(i + 1), "of", total, test['name'])

            # Note: as the test cases get more complex, you'll need to modify this
            # to pass down more arguments to the evm function
            code = bytes.fromhex(test['code']['bin'])
            stack = evm(code)

            expected_stack = [int(x) for x in test['expect']['stack']]

            if stack != expected_stack:
                print("Stack doesn't match")
                print(" expected:", expected_stack)
                print("   actual:", stack)
                print("")
                print("Test code:")
                print(test['code']['asm'])
                print("")
                print("Progress: " + str(i) + "/" + str(len(data)))
                print("")
                break


if __name__ == '__main__':
    test()