package evm

import (
	"encoding/hex"
	"encoding/json"
	"math/big"
	"os"
	"reflect"
	"slices"
	"testing"
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
	Stack   []string         `json:"stack"`
	Success *bool            `json:"success"`
	Return  *string          `json:"return"`
	Logs    []map[string]any `json:"logs"`
	State   map[string]any   `json:"state"`
}

func TestEVM(t *testing.T) {
	var tests []testCase
	t.Run("setup", func(t *testing.T) {
		testSrc := "../evm-pro.json"
		if _, err := os.Stat(testSrc); os.IsNotExist(err) {
			testSrc = "../evm.json"
		}
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

			got := Evm(bin)
			if tt.Want.Success != nil && got.Success != *tt.Want.Success {
				t.Errorf("Evm(…) got success = %t; want %t", got.Success, *tt.Want.Success)
			}
			if tt.Want.Stack != nil {
				wantStack := make([]*big.Int, len(tt.Want.Stack))
				for i, value := range tt.Want.Stack {
					n, ok := new(big.Int).SetString(value, 0)
					if !ok {
						fatalAndBugReport(t, "Invalid stack integer %q", value)
					}
					wantStack[i] = n
				}
				if !slices.EqualFunc(wantStack, got.Stack, func(want, got *big.Int) bool {
					return got != nil && want.Cmp(got) == 0
				}) {
					t.Errorf("Evm(…) stack mismatch; want %v, got %v", wantStack, got.Stack)
				}
			}

			if tt.Want.Return != nil && got.Return != *tt.Want.Return {
				t.Errorf("return mismatch; want %q, got %q", *tt.Want.Return, got.Return)
			}
			if tt.Want.Logs != nil {
				checkJSON(t, "logs", got.Logs, tt.Want.Logs)
			}
			if tt.Want.State != nil {
				checkJSON(t, "state", got.State, tt.Want.State)
			}

			if t.Failed() {
				t.Logf("✕  %v", tt.Name)
				instructions := tt.Code.Asm
				if instructions == "" {
					instructions = tt.Code.Bin
				}
				t.Logf("EVM Instructions:\n%v", instructions)
				if tt.Hint != "" {
					t.Log("#####")
					t.Logf("##### HINT: %s", tt.Hint)
					t.Log("#####")
				}
			}
		})
		if t.Failed() {
			t.Fatalf("Progress: %d/%d", i, len(tests))
		} else {
			t.Logf("✓  %v", tt.Name)
		}
	}
}

func checkJSON(t *testing.T, field string, got, want any) {
	t.Helper()
	normalize := func(value any) any {
		t.Helper()
		data, err := json.Marshal(value)
		if err != nil {
			t.Fatalf("%s: cannot encode value: %v", field, err)
		}
		var normalized any
		if err := json.Unmarshal(data, &normalized); err != nil {
			t.Fatalf("%s: cannot decode value: %v", field, err)
		}
		return normalized
	}
	if !reflect.DeepEqual(normalize(got), normalize(want)) {
		t.Errorf("%s mismatch; want %v, got %v", field, want, got)
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
