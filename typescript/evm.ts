/**
 * EVM From Scratch
 * TypeScript template
 *
 * To work on EVM From Scratch in TypeScript:
 *
 * - Install Node.js 24 or newer: https://nodejs.org/en/download/
 * - Go to the `typescript` directory: `cd typescript`
 * - Edit `evm.ts` (this file!), see TODO below
 * - Run `node evm.test.ts` to run the tests (no install needed)
 * - Run `node --watch evm.test.ts` to rerun when code changes
 * - Optional type checking: `npm install` then `npm run typecheck`
 */

type Result = {
  success: boolean;
  stack: bigint[];
};

export default function evm(code: Uint8Array): Result {
  let pc = 0;
  const stack: bigint[] = [];

  while (pc < code.length) {
    const opcode = code[pc];
    pc++;

    // TODO: implement the EVM here!
  }

  return { success: true, stack };
}
