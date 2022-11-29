use ethereum_types::U256;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Code {
    #[serde(default)]
    pub asm: Option<String>,
    #[serde(default)]
    pub bin: String,
}

pub struct EvmResult {
    pub stack: Vec<U256>,
    pub success: bool,
}

pub fn evm(_code: impl AsRef<[u8]>) -> EvmResult {
    let stack: Vec<U256> = Vec::new();
    let mut pc = 0;

    let code = _code.as_ref();

    while pc < code.len() {
        let opcode = code[pc];
        pc += 1;

        if opcode == 0x00 {
            // STOP
        }
    }

    // TODO: Implement me

    return EvmResult {
        stack,
        success: true,
    };
}
