# EVM From Scratch

![EVM From Scratch](.github/logo.png)

Welcome to **EVM From Scratch**! It's a 100% practical course that will help you better understand the inner workings of the Ethereum Virtual Machine. During this course, we'll implement EVM in your favorite programming language.

## Getting Started

Clone the repo:

```sh
git clone https://github.com/w1nt3r-eth/evm-from-scratch
```

This repository contains [`evm.json`](./evm.json) file with more than 100 test cases. Your goal is to create an implementation in any programming language of your choice that passes all tests.

The test cases are organized by complexity: they start with the simplest opcodes and gradually progress to advanced. Each test case has a name, code and expectation. The code is provided as a human-readable instructions list (`asm`) and machine-readable bytecode encoded in hex (`bin`). Your implementation should only look at `bin`, the `asm` is provided to make unit tests easier to debug.

The repository contains templates for JavaScript, TypeScript, Python, Go and Rust. However, you don't have to use the existing templates, you can build your own test suite based on [`evm.json`](./evm.json).

## Credits

All the materials in the repository are made by [w1nt3r.eth](https://twitter.com/w1nt3r_eth). The repository is part of the "EVM From Scratch" course (release date TBD).
