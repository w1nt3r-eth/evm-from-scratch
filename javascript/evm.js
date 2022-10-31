/**
 * EVM From Scratch
 * JavaScript template
 *
 * To work on EVM From Scratch in JavaScript:
 *
 * - Install Node.js: https://nodejs.org/en/download/
 * - Edit `javascript/evm.js` (this file!), see TODO below
 * - Run `node javascript/evm.js` to run the tests
 *
 * If you prefer TypeScript, there's a sample TypeScript template in the `typescript` directory.
 */

function evm(code) {
  // TODO: Implement me

  return { stack: [] };
}

function tests() {
  const tests = require("../evm.json");

  const hexStringToUint8Array = (hexString) =>
    new Uint8Array(hexString.match(/../g).map((byte) => parseInt(byte, 16)));

  const serializeBigInt = (key, value) =>
    typeof value === "bigint" ? "0x" + value.toString(16) : value;

  const total = Object.keys(tests).length;
  let passed = 0;

  try {
    for (const t of tests) {
      console.log("Test #" + (passed + 1), t.name);
      try {
        // Note: as the test cases get more complex, you'll need to modify this
        // to pass down more arguments to the evm function
        const result = evm(hexStringToUint8Array(t.code.bin));

        if (
          JSON.stringify(result.stack, serializeBigInt) !==
          JSON.stringify(t.expect.stack, serializeBigInt)
        ) {
          console.log("expected stack:", t.expect.stack);
          console.log(
            "  actual stack:",
            result.stack.map((b) => "0x" + b.toString(16))
          );
          throw new Error("Stack mismatch");
        }
      } catch (e) {
        console.log(`\n\nCode of the failing test (${t.name}):\n`);
        console.log(t.code.asm.replaceAll(/^/gm, "  "));
        console.log("\n");
        throw e;
      }
      passed++;
    }
  } finally {
    console.log(`Progress: ${passed}/${total}`);
  }
}

tests();
