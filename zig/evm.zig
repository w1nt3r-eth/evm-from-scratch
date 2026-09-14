// Zig 0.16: run `make zig` from the repository root.
const std = @import("std");

const Result = struct {
    success: bool,
    stack: std.ArrayList(u256),
};

fn evm(code: []const u8, allocator: std.mem.Allocator) !Result {
    var pc: usize = 0;
    const stack = try std.ArrayList(u256).initCapacity(allocator, 1024);

    while (pc < code.len) {
        const opcode = code[pc];
        pc += 1;
        _ = opcode;

        // TODO: implement the EVM here!
    }

    return .{ .success = true, .stack = stack };
}

const TestCase = struct {
    name: []const u8,
    hint: []const u8 = "",
    code: struct { bin: []const u8, @"asm": ?[]const u8 = null },
    expect: struct { success: bool, stack: ?[]const []const u8 = null },
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const cwd = std.Io.Dir.cwd();
    const json = cwd.readFileAlloc(init.io, "../evm-pro.json", allocator, .unlimited) catch |err| switch (err) {
        error.FileNotFound => try cwd.readFileAlloc(init.io, "../evm.json", allocator, .unlimited),
        else => return err,
    };
    const parsed = try std.json.parseFromSlice([]TestCase, allocator, json, .{ .ignore_unknown_fields = true });
    const tests = parsed.value;

    for (tests, 0..) |test_case, index| {
        std.debug.print("Test #{d}/{d}: {s}\n", .{ index + 1, tests.len, test_case.name });
        const code = try allocator.alloc(u8, test_case.code.bin.len / 2);
        _ = try std.fmt.hexToBytes(code, test_case.code.bin);
        // As tests get more complex, pass more inputs to evm and check more outputs.
        const result = try evm(code, allocator);
        const stack_values = test_case.expect.stack orelse &.{};
        const expected_stack = try allocator.alloc(u256, stack_values.len);
        for (stack_values, 0..) |value, i| {
            expected_stack[i] = try std.fmt.parseInt(u256, value, 0);
        }

        if (result.success != test_case.expect.success or (test_case.expect.stack != null and !std.mem.eql(u256, result.stack.items, expected_stack))) {
            std.debug.print("Expected success: {}; got: {}\n", .{ test_case.expect.success, result.success });
            std.debug.print("Expected stack: {any}\nActual stack: {any}\n", .{ expected_stack, result.stack.items });
            std.debug.print("Instructions:\n{s}\n", .{test_case.code.@"asm" orelse test_case.code.bin});
            std.debug.print("Hint: {s}\nProgress: {d}/{d}\n", .{ test_case.hint, index, tests.len });
            std.process.exit(1);
        }
    }
    std.debug.print("Progress: {d}/{d}\n", .{ tests.len, tests.len });
}
