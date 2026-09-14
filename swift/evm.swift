// Swift 6+: run `make swift` from the repository root.
import BigInt
import Foundation

func evm(_ code: [UInt8]) -> (success: Bool, stack: [BigUInt]) {
    var pc = 0
    let stack: [BigUInt] = []

    while pc < code.count {
        let opcode = code[pc]
        pc += 1
        _ = opcode

        // TODO: implement the EVM here!
    }

    return (true, stack)
}

struct TestCase: Decodable {
    let name: String
    let hint: String?
    let code: Code
    let expect: Expected

    struct Code: Decodable {
        let bin: String
        let asm: String?
    }
    struct Expected: Decodable {
        let success: Bool
        let stack: [String]?
    }
}

enum TestDataError: Error {
    case invalidHex(String)
    case invalidInteger(String)
}

func decodeHex(_ hex: String) throws -> [UInt8] {
    guard hex.count.isMultiple(of: 2) else { throw TestDataError.invalidHex(hex) }
    let chars = Array(hex)
    return try stride(from: 0, to: chars.count, by: 2).map {
        guard let byte = UInt8(String(chars[$0...$0 + 1]), radix: 16) else {
            throw TestDataError.invalidHex(hex)
        }
        return byte
    }
}

func parseInteger(_ value: String) throws -> BigUInt {
    let hex = value.hasPrefix("0x")
    guard let integer = BigUInt(hex ? String(value.dropFirst(2)) : value, radix: hex ? 16 : 10) else {
        throw TestDataError.invalidInteger(value)
    }
    return integer
}

let testFile = FileManager.default.fileExists(atPath: "../evm-pro.json")
    ? "../evm-pro.json" : "../evm.json"
let tests: [TestCase]
do {
    let data = try Data(contentsOf: URL(fileURLWithPath: testFile))
    tests = try JSONDecoder().decode([TestCase].self, from: data)
} catch {
    print("Could not load \(testFile): \(error)")
    exit(1)
}

do {
    for (index, test) in tests.enumerated() {
        print("Test #\(index + 1)/\(tests.count): \(test.name)")
        // As tests get more complex, pass more inputs to evm and check more outputs.
        let result = evm(try decodeHex(test.code.bin))
        let expectedStack = try test.expect.stack?.map(parseInteger)

        let stackMatches = expectedStack.map { $0 == result.stack } ?? true
        if result.success != test.expect.success || !stackMatches {
            print("Expected success: \(test.expect.success); got: \(result.success)")
            if let expectedStack { print("Expected stack: \(expectedStack)") }
            print("Actual stack: \(result.stack)")
            print("Instructions:\n\(test.code.asm ?? test.code.bin)")
            if let hint = test.hint { print("Hint: \(hint)") }
            print("Progress: \(index)/\(tests.count)")
            exit(1)
        }
    }
} catch {
    print("Invalid test data: \(error)")
    exit(1)
}
print("Progress: \(tests.count)/\(tests.count)")
