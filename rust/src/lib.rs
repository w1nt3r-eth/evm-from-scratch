use primitive_types::U256;

pub struct EvmResult {
    pub stack: Vec<U256>,
    pub success: bool,
}

pub fn evm(_code: impl AsRef<[u8]>) -> EvmResult {
    // TODO: Implement me

    return EvmResult {
        stack: vec![],
        success: true,
    };
}
