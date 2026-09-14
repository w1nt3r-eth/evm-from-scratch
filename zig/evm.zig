// Zig 0.16: run `make zig` from the repository root.
const std = @import("std");

const Result = struct {
    success: bool,
    stack: std.ArrayList(u256),
    return_data: []const u8 = "",
    logs: std.json.Value,
    state: std.json.Value,
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

    return .{
        .success = true,
        .stack = stack,
        .logs = .{ .array = std.json.Array.init(allocator) },
        .state = .{ .object = std.json.ObjectMap{} },
    };
}

const TestCase = struct {
    name: []const u8,
    hint: []const u8 = "",
    code: struct { bin: []const u8, @"asm": ?[]const u8 = null },
    expect: struct {
        success: ?bool = null,
        stack: ?[]const []const u8 = null,
        @"return": ?[]const u8 = null,
        logs: ?std.json.Value = null,
        state: ?std.json.Value = null,
    },
};

fn jsonEqual(a: std.json.Value, b: std.json.Value) bool {
    if (std.meta.activeTag(a) != std.meta.activeTag(b)) return false;
    return switch (a) {
        .null => true,
        .bool => |v| v == b.bool,
        .integer => |v| v == b.integer,
        .float => |v| v == b.float,
        .number_string => |v| std.mem.eql(u8, v, b.number_string),
        .string => |v| std.mem.eql(u8, v, b.string),
        .array => |v| blk: {
            if (v.items.len != b.array.items.len) break :blk false;
            for (v.items, b.array.items) |left, right| {
                if (!jsonEqual(left, right)) break :blk false;
            }
            break :blk true;
        },
        .object => |v| blk: {
            if (v.count() != b.object.count()) break :blk false;
            var entries = v.iterator();
            while (entries.next()) |entry| {
                const other = b.object.get(entry.key_ptr.*) orelse break :blk false;
                if (!jsonEqual(entry.value_ptr.*, other)) break :blk false;
            }
            break :blk true;
        },
    };
}

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
        // As tests get more complex, pass more inputs to evm.
        const result = try evm(code, allocator);
        const stack_values = test_case.expect.stack orelse &.{};
        const expected_stack = try allocator.alloc(u256, stack_values.len);
        for (stack_values, 0..) |value, i| {
            expected_stack[i] = try std.fmt.parseInt(u256, value, 0);
        }

        var outputs_match = true;
        if (test_case.expect.@"return") |value| {
            if (!std.mem.eql(u8, result.return_data, value)) {
                std.debug.print("return mismatch: expected {s}; got {s}\n", .{ value, result.return_data });
                outputs_match = false;
            }
        }
        if (test_case.expect.logs) |value| {
            if (!jsonEqual(result.logs, value)) {
                std.debug.print("logs mismatch\n", .{});
                outputs_match = false;
            }
        }
        if (test_case.expect.state) |value| {
            if (!jsonEqual(result.state, value)) {
                std.debug.print("state mismatch\n", .{});
                outputs_match = false;
            }
        }
        const success_matches = if (test_case.expect.success) |value| result.success == value else true;
        if (!outputs_match or !success_matches or (test_case.expect.stack != null and !std.mem.eql(u256, result.stack.items, expected_stack))) {
            std.debug.print("Expected success: {any}; got: {}\n", .{ test_case.expect.success, result.success });
            std.debug.print("Expected stack: {any}\nActual stack: {any}\n", .{ expected_stack, result.stack.items });
            std.debug.print("Instructions:\n{s}\n", .{test_case.code.@"asm" orelse test_case.code.bin});
            std.debug.print("Hint: {s}\nProgress: {d}/{d}\n", .{ test_case.hint, index, tests.len });
            std.process.exit(1);
        }
    }
    std.debug.print("Progress: {d}/{d}\n", .{ tests.len, tests.len });
}
