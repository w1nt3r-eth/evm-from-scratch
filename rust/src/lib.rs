use primitive_types::U256;

pub struct EvmResult {
    pub stack: Vec<U256>,
    pub success: bool,
}

pub fn evm(code: &[u8]) -> EvmResult {
    let stack: Vec<U256> = Vec::new();
    let mut pc = 0;

    while pc < code.len() {
        let _opcode = code[pc];
        pc += 1;

        // TODO: implement the EVM here!
    }

    EvmResult {
        stack,
        success: true,
    }
}
