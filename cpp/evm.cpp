// C++20: run `make cpp` from the repository root.
#include "intx.hpp"
#include "json.hpp"
#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

using intx::uint256;
using nlohmann::json;

struct Result {
    bool success;
    std::vector<uint256> stack;
    std::string return_data;
    json logs = json::array();
    json state = json::object();
};

Result evm(const std::vector<uint8_t>& code) {
    size_t pc = 0;
    std::vector<uint256> stack;

    while (pc < code.size()) {
        [[maybe_unused]] const auto opcode = code[pc++];

        // TODO: implement the EVM here!
    }

    return {true, std::move(stack)};
}

std::vector<uint8_t> decode_hex(const std::string& hex) {
    if (hex.size() % 2 != 0) throw std::runtime_error("Invalid bytecode hex");
    std::vector<uint8_t> bytes;
    for (size_t i = 0; i < hex.size(); i += 2) {
        size_t consumed = 0;
        auto byte = std::stoul(hex.substr(i, 2), &consumed, 16);
        if (consumed != 2) throw std::runtime_error("Invalid bytecode hex");
        bytes.push_back(static_cast<uint8_t>(byte));
    }
    return bytes;
}

void print_stack(const std::vector<uint256>& stack) {
    std::cout << '[';
    for (size_t i = 0; i < stack.size(); ++i) {
        if (i) std::cout << ", ";
        std::cout << intx::to_string(stack[i]);
    }
    std::cout << "]\n";
}

int main() {
    const auto test_file = std::filesystem::exists("../evm-pro.json")
        ? "../evm-pro.json" : "../evm.json";
    std::ifstream input(test_file);
    const auto tests = json::parse(input);

    for (size_t i = 0; i < tests.size(); ++i) {
        const auto& test = tests[i];
        std::cout << "Test #" << i + 1 << '/' << tests.size() << ": " << test.at("name").get<std::string>() << '\n';
        const auto& code = test.at("code");
        const auto& expected = test.at("expect");
        // As tests get more complex, pass more inputs to evm.
        const auto result = evm(decode_hex(code.at("bin").get<std::string>()));
        std::vector<uint256> expected_stack;
        const bool check_stack = expected.contains("stack") && !expected.at("stack").is_null();
        if (check_stack) {
            for (const auto& value : expected.at("stack")) {
                expected_stack.push_back(intx::from_string<uint256>(value.get<std::string>()));
            }
        }
        const bool check_success = expected.contains("success") && !expected.at("success").is_null();
        const bool expected_success = check_success ? expected.at("success").get<bool>() : result.success;
        const json outputs = {{"return", result.return_data}, {"logs", result.logs}, {"state", result.state}};
        bool outputs_match = true;
        for (const auto& [field, actual] : outputs.items()) {
            if (expected.contains(field) && !expected.at(field).is_null() && expected.at(field) != actual) {
                std::cout << field << " mismatch: expected " << expected.at(field) << "; got " << actual << '\n';
                outputs_match = false;
            }
        }

        if (!outputs_match || result.success != expected_success || (check_stack && result.stack != expected_stack)) {
            std::cout << std::boolalpha << "Expected success: " << expected_success << "; got: " << result.success << '\n';
            std::cout << "Expected stack: "; print_stack(expected_stack);
            std::cout << "Actual stack: "; print_stack(result.stack);
            std::cout << "Instructions:\n" << (code.at("asm").is_null() ? code.at("bin") : code.at("asm")).get<std::string>() << '\n';
            std::cout << "Hint: " << test.value("hint", "") << '\n';
            std::cout << "Progress: " << i << '/' << tests.size() << '\n';
            return 1;
        }
    }
    std::cout << "Progress: " << tests.size() << '/' << tests.size() << '\n';
}
