# Contributing

If you'd like to contribute, open an issue or a pull request.

The top priorities are:

- Adding templates for the most popular programming languages
- Adding more EVM unit tests
- Validate existing unit tests against production library (like geth)

## Adding templates

You can check out the existing templates to see the general structure. Requirements for the templates:

- Minimal dependencies on tools and libraries
- Initial code should not have more scaffolding than necessary to pass the first dozen tests
- The tests should run sequentially and bail as soon as at least one test fails. It helps the students focus on one thing at a time
- The tests should provide a sense of progress, e.g. displaying "test 3 of 100" in the output
- When a test fails, print the assembly code, expected results and actual results

Please add a template only if you are very familiar with the programming language. Use [TIOBE Index](https://www.tiobe.com/tiobe-index/) to get a sense of which languages to add.

## Adding unit tests

The source code of the unit tests is stored in [`scripts/evm.yaml`](scripts/evm.yaml). YAML is much easier to write than JSON, but JSON is much easier to consume from a wide range of programming languages.

The code in `scripts` is used to transform YAML to JSON. All numbers and addresses are stored as strings to avoid parsing issues (many programming languages by default parse numbers into int64 or even floats, which can't handle uint256 used by the EVM). Note that we append `n` to decimal and hexadecimal numbers to avoid YAML treating them as numbers (and overflowing).

During this process, we also compile assembly instructions into bytecode.

To build `evm.json` from `evm.yaml`:

```sh
$ cd scripts
$ yarn install
$ node index.js
```

Currently there's no reference implementation. The plan is to use [Ethereum's official EVM implementation](https://github.com/ethereumjs/ethereumjs-monorepo) to verify the unit tests are valid.
