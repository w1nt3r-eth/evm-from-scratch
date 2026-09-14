// Package evm is an **incomplete** implementation of the Ethereum Virtual
// Machine for the "EVM From Scratch" course:
// https://github.com/w1nt3r-eth/evm-from-scratch
//
// To work on EVM From Scratch In Go:
//
// - Install Golang: https://golang.org/doc/install
// - Go to the `go` directory: `cd go`
// - Edit `evm.go` (this file!), see TODO below
// - Run `go test -count=1 ./...` to run the tests without caching the JSON suite
package evm

import (
	"math/big"
)

type Result struct {
	Success bool
	Stack   []*big.Int
	Return  string
	Logs    []map[string]any
	State   map[string]any
}

func Evm(code []byte) Result {
	var stack []*big.Int
	pc := 0

	for pc < len(code) {
		op := code[pc]
		pc++

		// TODO: Implement the EVM here!
		_ = op // delete this; it's only here to make the compiler think you're already using `op`
	}

	return Result{Success: true, Stack: stack, Logs: []map[string]any{}, State: map[string]any{}}
}
