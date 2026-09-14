// Kotlin 2.2+: run `make kotlin` from the repository root.
import com.google.gson.JsonParser
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.io.File
import java.math.BigInteger
import kotlin.system.exitProcess

data class Result(
    val success: Boolean,
    val stack: List<BigInteger>,
    val returnData: String = "",
    val logs: JsonArray = JsonArray(),
    val state: JsonObject = JsonObject()
)

fun evm(code: ByteArray): Result {
    var pc = 0
    val stack = mutableListOf<BigInteger>()

    while (pc < code.size) {
        val opcode = code[pc++].toInt() and 0xff

        // TODO: implement the EVM here!
    }

    return Result(true, stack)
}

fun parseInteger(value: String) = if (value.startsWith("0x"))
    BigInteger(value.substring(2), 16) else BigInteger(value)

val proFile = File("../evm-pro.json")
val testFile = if (proFile.exists()) proFile else File("../evm.json")
val tests = JsonParser.parseString(testFile.readText()).asJsonArray

for ((index, item) in tests.withIndex()) {
    val test = item.asJsonObject
    println("Test #${index + 1}/${tests.size()}: ${test["name"].asString}")
    val code = test.getAsJsonObject("code")
    val expected = test.getAsJsonObject("expect")
    // As tests get more complex, pass more inputs to evm.
    val result = evm(code["bin"].asString.hexToByteArray())
    val expectedStack = expected["stack"]?.takeUnless { it.isJsonNull }?.asJsonArray?.map { parseInteger(it.asString) }
    val expectedSuccess = expected["success"]?.takeUnless { it.isJsonNull }?.asBoolean
    val outputs = JsonObject().apply {
        addProperty("return", result.returnData)
        add("logs", result.logs)
        add("state", result.state)
    }
    var outputsMatch = true
    for ((field, actual) in outputs.entrySet()) {
        val value = expected[field]
        if (value != null && !value.isJsonNull && value != actual) {
            println("$field mismatch: expected $value; got $actual")
            outputsMatch = false
        }
    }

    if (!outputsMatch || (expectedSuccess != null && result.success != expectedSuccess) || (expectedStack != null && result.stack != expectedStack)) {
        println("Expected success: $expectedSuccess; got: ${result.success}")
        println("Expected stack: $expectedStack\nActual stack: ${result.stack}")
        val asm = code["asm"]
        println("Instructions:\n${if (asm == null || asm.isJsonNull) code["bin"].asString else asm.asString}")
        if (test.has("hint")) println("Hint: ${test["hint"].asString}")
        println("Progress: $index/${tests.size()}")
        exitProcess(1)
    }
}
println("Progress: ${tests.size()}/${tests.size()}")
