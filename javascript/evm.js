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

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

function evm(code) {
  let pc = 0;
  const stack = [];

  while (pc < code.length) {
    const opcode = code[pc];
    pc++;

    // TODO: implement the EVM here!
  }

  return { success: true, stack };
}

function tests() {
  const proFile = path.join(__dirname, "../evm-pro.json");
  const testFile = fs.existsSync(proFile) ? proFile : path.join(__dirname, "../evm.json");
  const tests = JSON.parse(fs.readFileSync(testFile, "utf8"));
  let passed = 0;

  for (const t of tests) {
    console.log(`Test #${passed + 1}/${tests.length}: ${t.name}`);
    try {
      // As the tests get more complex, pass more inputs to evm and check more outputs.
      const result = evm(Buffer.from(t.code.bin, "hex"));
      assert.equal(result.success, t.expect.success, "Success mismatch");
      if (t.expect.stack != null) {
        assert.deepEqual(result.stack, t.expect.stack.map(BigInt), "Stack mismatch");
      }
      passed++;
    } catch (error) {
      console.error(error);
      console.error(`Instructions:\n${t.code.asm ?? t.code.bin}`);
      if (t.hint) console.error(`Hint: ${t.hint}`);
      process.exitCode = 1;
      break;
    }
  }
  console.log(`Progress: ${passed}/${tests.length}`);
}

tests();
