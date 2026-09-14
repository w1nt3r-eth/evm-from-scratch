// .NET 10+: run `make csharp` from the repository root.
using System.Globalization;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Nodes;

static (bool Success, List<BigInteger> Stack, string ReturnData, JsonArray Logs, JsonObject State) Evm(byte[] code)
{
    var pc = 0;
    var stack = new List<BigInteger>();

    while (pc < code.Length)
    {
        var opcode = code[pc++];

        // TODO: implement the EVM here!
    }

    return (true, stack, "", new JsonArray(), new JsonObject());
}

static BigInteger ParseInteger(string value) => value.StartsWith("0x")
    ? BigInteger.Parse("0" + value[2..], NumberStyles.HexNumber)
    : BigInteger.Parse(value);

var testFile = File.Exists("../evm-pro.json") ? "../evm-pro.json" : "../evm.json";
using var document = JsonDocument.Parse(File.ReadAllText(testFile));
var tests = document.RootElement;
var passed = 0;

foreach (var test in tests.EnumerateArray())
{
    Console.WriteLine($"Test #{passed + 1}/{tests.GetArrayLength()}: {test.GetProperty("name").GetString()}");
    var code = test.GetProperty("code");
    var expected = test.GetProperty("expect");
    // As tests get more complex, pass more inputs to Evm.
    var result = Evm(Convert.FromHexString(code.GetProperty("bin").GetString()!));
    var expectedStack = expected.TryGetProperty("stack", out var stack) && stack.ValueKind != JsonValueKind.Null
        ? stack.EnumerateArray().Select(value => ParseInteger(value.GetString()!)).ToList()
        : null;
    bool? expectedSuccess = expected.TryGetProperty("success", out var success) && success.ValueKind != JsonValueKind.Null
        ? success.GetBoolean() : null;
    var outputs = new JsonObject { ["return"] = result.ReturnData, ["logs"] = result.Logs, ["state"] = result.State };
    var outputsMatch = true;
    foreach (var (field, actual) in outputs)
    {
        if (expected.TryGetProperty(field, out var value) && value.ValueKind != JsonValueKind.Null
            && !JsonNode.DeepEquals(JsonNode.Parse(value.GetRawText()), actual))
        {
            Console.WriteLine($"{field} mismatch: expected {value}; got {actual}");
            outputsMatch = false;
        }
    }

    if (!outputsMatch || (expectedSuccess != null && result.Success != expectedSuccess) || (expectedStack != null && !result.Stack.SequenceEqual(expectedStack)))
    {
        Console.WriteLine($"Expected success: {expectedSuccess}; got: {result.Success}");
        if (expectedStack != null) Console.WriteLine($"Expected stack: [{string.Join(", ", expectedStack)}]");
        Console.WriteLine($"Actual stack: [{string.Join(", ", result.Stack)}]");
        Console.WriteLine($"Instructions:\n{code.GetProperty("asm").GetString() ?? code.GetProperty("bin").GetString()}");
        if (test.TryGetProperty("hint", out var hint)) Console.WriteLine($"Hint: {hint.GetString()}");
        Environment.ExitCode = 1;
        break;
    }
    passed++;
}
Console.WriteLine($"Progress: {passed}/{tests.GetArrayLength()}");
