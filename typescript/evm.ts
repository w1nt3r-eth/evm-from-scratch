/**
 * EVM From Scratch
 * TypeScript template
 *
 * To work on EVM From Scratch in TypeScript:
 *
 * - Install Node.js: https://nodejs.org/en/download/
 * - Go to the `typescript` directory: `cd typescript`
 * - Install dependencies: `yarn` (or `npm install`)
 * - Edit `evm.ts` (this file!), see TODO below
 * - Run `yarn test` (or `npm test`) to run the tests
 * - Use Jest Watch Mode to run tests when files change: `yarn test --watchAll`
 */

type Result = {
  success: boolean,
  stack: bigint[]
}

export default function evm(code: Uint8Array): Result {
  let pc = 0;
  let stack = [];

  while (pc < code.length) {
    const opcode = code[pc];
    pc++;

    // TODO: implement the EVM here!
  }

  return { success: true, stack };
}
