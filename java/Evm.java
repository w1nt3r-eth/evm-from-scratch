// Java 25+: run `make java` from the repository root.
import com.google.gson.JsonParser;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;

record Result(boolean success, List<BigInteger> stack) {}

Result evm(byte[] code) {
    int pc = 0;
    var stack = new ArrayList<BigInteger>();

    while (pc < code.length) {
        int opcode = Byte.toUnsignedInt(code[pc++]);

        // TODO: implement the EVM here!
    }

    return new Result(true, stack);
}

BigInteger parseInteger(String value) {
    return value.startsWith("0x")
        ? new BigInteger(value.substring(2), 16)
        : new BigInteger(value);
}

void main() throws Exception {
    var proFile = Path.of("../evm-pro.json");
    var testFile = Files.exists(proFile) ? proFile : Path.of("../evm.json");
    var tests = JsonParser.parseString(Files.readString(testFile)).getAsJsonArray();
    int passed = 0;

    for (var item : tests) {
        var test = item.getAsJsonObject();
        System.out.printf("Test #%d/%d: %s%n", passed + 1, tests.size(), test.get("name").getAsString());
        var code = test.getAsJsonObject("code");
        var expected = test.getAsJsonObject("expect");
        // As tests get more complex, pass more inputs to evm and check more outputs.
        var result = evm(HexFormat.of().parseHex(code.get("bin").getAsString()));
        var expectedStack = new ArrayList<BigInteger>();
        var stack = expected.getAsJsonArray("stack");
        if (stack != null) {
            for (var value : stack) expectedStack.add(parseInteger(value.getAsString()));
        }
        boolean expectedSuccess = expected.get("success").getAsBoolean();

        if (result.success() != expectedSuccess || (stack != null && !result.stack().equals(expectedStack))) {
            System.out.printf("Expected success: %s; got: %s%n", expectedSuccess, result.success());
            System.out.printf("Expected stack: %s%nActual stack: %s%n", expectedStack, result.stack());
            var asm = code.get("asm");
            System.out.println("Instructions:\n" + (asm == null || asm.isJsonNull() ? code.get("bin").getAsString() : asm.getAsString()));
            if (test.has("hint")) System.out.println("Hint: " + test.get("hint").getAsString());
            System.out.printf("Progress: %d/%d%n", passed, tests.size());
            System.exit(1);
        }
        passed++;
    }
    System.out.printf("Progress: %d/%d%n", passed, tests.size());
}
