// Swift 6+: run `make swift` from the repository root.
import BigInt
import Foundation

enum JSONValue: Decodable, Equatable {
    case null, bool(Bool), number(Double), string(String)
    case array([JSONValue]), object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if value.decodeNil() { self = .null }
        else if let bool = try? value.decode(Bool.self) { self = .bool(bool) }
        else if let string = try? value.decode(String.self) { self = .string(string) }
        else if let number = try? value.decode(Double.self) { self = .number(number) }
        else if let array = try? value.decode([JSONValue].self) { self = .array(array) }
        else { self = .object(try value.decode([String: JSONValue].self)) }
    }
}

struct Result {
    var success: Bool
    var stack: [BigUInt]
    var returnData = ""
    var logs: [JSONValue] = []
    var state: [String: JSONValue] = [:]
}

func evm(_ code: [UInt8]) -> Result {
    var pc = 0
    let stack: [BigUInt] = []

    while pc < code.count {
        let opcode = code[pc]
        pc += 1
        _ = opcode

        // TODO: implement the EVM here!
    }

    return Result(success: true, stack: stack)
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
        let success: Bool?
        let stack: [String]?
        let `return`: String?
        let logs: [JSONValue]?
        let state: [String: JSONValue]?
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
        // As tests get more complex, pass more inputs to evm.
        let result = evm(try decodeHex(test.code.bin))
        let expectedStack = try test.expect.stack?.map(parseInteger)

        let stackMatches = expectedStack.map { $0 == result.stack } ?? true
        let successMatches = test.expect.success.map { $0 == result.success } ?? true
        var outputsMatch = true
        if let expected = test.expect.return, expected != result.returnData {
            print("return mismatch: expected \(expected); got \(result.returnData)")
            outputsMatch = false
        }
        if let expected = test.expect.logs, expected != result.logs {
            print("logs mismatch: expected \(expected); got \(result.logs)")
            outputsMatch = false
        }
        if let expected = test.expect.state, expected != result.state {
            print("state mismatch: expected \(expected); got \(result.state)")
            outputsMatch = false
        }
        if !successMatches || !stackMatches || !outputsMatch {
            print("Expected success: \(String(describing: test.expect.success)); got: \(result.success)")
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
