use evm::evm;
use primitive_types::U256;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct Evmtest {
    name: String,
    code: Code,
    expect: Expect,
}

#[derive(Debug, Deserialize)]
struct Code {
    asm: String,
    bin: String,
}

#[derive(Debug, Deserialize)]
struct Expect {
    stack: Option<Vec<String>>,
    success: Option<bool>,
    #[serde(rename = "return")]
    ret: Option<String>,
}

fn main() {
    let text = std::fs::read_to_string("../evm.json").unwrap();
    let data: Vec<Evmtest> = serde_json::from_str(&text).unwrap();

    let total = data.len();

    for (index, test) in data.iter().enumerate() {
        println!("Test {} of {}: {}", index + 1, total, test.name);

        let code: Vec<u8> = hex::decode(&test.code.bin).unwrap();

        let actual_stack = evm(&code);

        let mut expected_stack: Vec<U256> = Vec::new();
        if let Some(ref stacks) = test.expect.stack {
            for stack in stacks {
                expected_stack.push(stack.parse().unwrap());
            }
        }

        let mut matching = actual_stack.len() == expected_stack.len();
        if matching {
            for i in 0..actual_stack.len() {
                if actual_stack[i] != expected_stack[i] {
                    matching = false;
                    break;
                }
            }
        }

        if !matching {
            println!("Instructions: \n{}\n", test.code.asm);

            println!("Expected: [");
            for v in expected_stack {
                println!("  {:#X},", v);
            }
            println!("]\n");

            println!("Got: [");
            for v in actual_stack {
                println!("  {:#X},", v);
            }
            println!("]\n");

            println!("Progress: {}/{}\n\n", index, total);
            panic!("Stack mismatch");
        }
        println!("PASS");
    }
    println!("Congratulations!");
}
