/**
 * EVM From Scratch
 * Rust template
 *
 * To work on EVM From Scratch in Rust:
 *
 * - Install Rust: https://www.rust-lang.org/tools/install
 * - Edit `rust/src/lib.rs`
 * - Run `cd rust && cargo run` to run the tests
 *
 * Hint: most people who were trying to learn Rust and EVM at the same
 * gave up and switched to JavaScript, Python, or Go. If you are new
 * to Rust, implement EVM in another programming language first.
 */
use evm::evm;
use primitive_types::U256;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct TestCase {
    name: String,
    hint: String,
    code: Code,
    expect: Expect,
}

#[derive(Debug, Deserialize)]
struct Code {
    asm: Option<String>,
    bin: String,
}

#[derive(Debug, Deserialize)]
struct Expect {
    stack: Option<Vec<String>>,
    success: Option<bool>,
    #[serde(rename = "return")]
    return_data: Option<String>,
    logs: Option<Vec<serde_json::Value>>,
    state: Option<serde_json::Map<String, serde_json::Value>>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let test_file = if std::path::Path::new("../evm-pro.json").exists() {
        "../evm-pro.json"
    } else {
        "../evm.json"
    };
    let text = std::fs::read_to_string(test_file)?;
    let data: Vec<TestCase> = serde_json::from_str(&text)?;

    let total = data.len();

    for (index, test) in data.iter().enumerate() {
        println!("Test {} of {}: {}", index + 1, total, test.name);

        let code: Vec<u8> = hex::decode(&test.code.bin)?;

        let result = evm(&code);

        let mut expected_stack: Vec<U256> = Vec::new();
        if let Some(ref stacks) = test.expect.stack {
            for value in stacks {
                expected_stack.push(U256::from_str_radix(value, 16)?);
            }
        }

        let stack_matches = test.expect.stack.is_none() || result.stack == expected_stack;
        let mut matching = stack_matches
            && test
                .expect
                .success
                .is_none_or(|value| result.success == value);
        if let Some(ref value) = test.expect.return_data {
            if &result.return_data != value {
                println!(
                    "return mismatch: expected {value:?}, got {:?}",
                    result.return_data
                );
                matching = false;
            }
        }
        if let Some(ref value) = test.expect.logs {
            if &result.logs != value {
                println!("logs mismatch: expected {value:?}, got {:?}", result.logs);
                matching = false;
            }
        }
        if let Some(ref value) = test.expect.state {
            if &result.state != value {
                println!("state mismatch: expected {value:?}, got {:?}", result.state);
                matching = false;
            }
        }

        if !matching {
            println!(
                "Instructions: \n{}\n",
                test.code.asm.as_deref().unwrap_or(&test.code.bin)
            );

            println!("Expected success: {:?}", test.expect.success);
            println!("Expected stack: [");
            for v in expected_stack {
                println!("  {:#X},", v);
            }
            println!("]\n");

            println!("Actual success: {:?}", result.success);
            println!("Actual stack: [");
            for v in result.stack {
                println!("  {:#X},", v);
            }
            println!("]\n");

            println!("\nHint: {}\n", test.hint);
            println!("Progress: {}/{}\n\n", index, total);
            std::process::exit(1);
        }
        println!("PASS");
    }
    println!("Congratulations!");
    Ok(())
}
