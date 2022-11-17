package evm

import (
	"encoding/hex"
	"encoding/json"
	"math/big"
	"os"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
)

type testCase struct {
	Name string `json:"name"`
	Hint string `json:"hint"`
	Code code   `json:"code"`
	Want want   `json:"expect"`
}

type code struct {
	Bin string `json:"bin"`
	Asm string `json:"asm"`
}

type want struct {
	Stack   []hexBigInt `json:"stack"`
	Success bool        `json:"success"`
	Return  string      `json:"return"`
}

// A hexBigInt is a *big.Int that can be read from a JSON hex string.
type hexBigInt struct {
	*big.Int
}

// UnmarshalJSON unmarshals the buffer into i.Int; it expects the input to be
// string-quoted.
func (i *hexBigInt) UnmarshalJSON(b []byte) error {
	var s string
	if err := json.Unmarshal(b, &s); err != nil {
		return err
	}
	if i.Int == nil {
		i.Int = new(big.Int)
	}
	return i.Int.UnmarshalJSON([]byte(s))
}

// StackInts returns the underlying *big.Int values of w.Stack, unwrapping them
// from within the JSON-unmarshalling helper.
func (w *want) StackInts() []*big.Int {
	b := make([]*big.Int, len(w.Stack))
	for i, s := range w.Stack {
		b[i] = s.Int
	}
	return b
}

func TestEVM(t *testing.T) {
	var tests []testCase
	t.Run("setup", func(t *testing.T) {
		const testSrc = "../evm.json"
		f, err := os.Open(testSrc)
		if err != nil {
			fatalAndBugReport(t, "os.Open(%q) error %v", testSrc, err)
		}
		defer f.Close()

		if err := json.NewDecoder(f).Decode(&tests); err != nil {
			fatalAndBugReport(t, "json.NewDecoder(%q).Decode(%T) error %v", testSrc, &tests, err)
		}
	})
	if t.Failed() {
		return
	}

	for i, tt := range tests {
		t.Run(tt.Name, func(t *testing.T) {
			bin, err := hex.DecodeString(tt.Code.Bin)
			if err != nil {
				fatalAndBugReport(t, "hex.DecodeString(%q) error %v", tt.Code.Bin, err)
			}

			got, gotSuccess := Run(bin)
			if gotSuccess != tt.Want.Success {
				t.Errorf("Run(…) got success = %t; want %t", gotSuccess, tt.Want.Success)
			}
			if diff := cmp.Diff(tt.Want.StackInts(), got, cmpopts.EquateEmpty()); diff != "" {
				t.Errorf("Run(…) stack mismatch; diff (-want +got)\n%s", diff)
			}

			if t.Failed() {
				t.Logf("EVM Instructions:\n%v", tt.Code.Asm)
				if tt.Hint != "" {
					t.Log("#####")
					t.Logf("##### HINT: %s", tt.Hint)
					t.Log("#####")
				}
			}
		})
		if t.Failed() {
			t.Fatalf("Progress: %d/%d", i, len(tests))
		}
	}
}

// fatalAndBugReport calls t.Errorf(format, a...) and then t.Fatal() with a
// message requesting that the student files a bug report. It's intended use is
// as a replacement for t.Fatal() when the error is in the test setup, not in
// the student's implementation.
func fatalAndBugReport(t *testing.T, format string, a ...interface{}) {
	t.Helper()
	t.Errorf(format, a...)
	t.Fatal("The error wasn't in your code. Please file a bug report at https://github.com/w1nt3r-eth/evm-from-scratch/issues/new")
}
