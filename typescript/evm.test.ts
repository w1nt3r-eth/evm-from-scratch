import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import evm from "./evm.ts";

type TestCase = {
  name: string;
  hint: string;
  code: { bin: string; asm: string | null };
  expect: { success: boolean; stack: string[] };
};

const proFile = new URL("../evm-pro.json", import.meta.url);
const testFile = existsSync(proFile) ? proFile : new URL("../evm.json", import.meta.url);
const tests: TestCase[] = JSON.parse(readFileSync(testFile, "utf8"));
let passed = 0;

for (const t of tests) {
  console.log(`Test #${passed + 1}/${tests.length}: ${t.name}`);
  try {
    // As the tests get more complex, pass more inputs to evm and check more outputs.
    const result = evm(Buffer.from(t.code.bin, "hex"));
    assert.equal(result.success, t.expect.success, "Success mismatch");
    assert.deepEqual(result.stack, t.expect.stack.map(BigInt), "Stack mismatch");
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
