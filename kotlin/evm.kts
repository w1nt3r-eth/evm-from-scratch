// Kotlin 2.2+: run `make kotlin` from the repository root.
import com.google.gson.JsonParser
import java.io.File
import java.math.BigInteger
import kotlin.system.exitProcess

data class Result(val success: Boolean, val stack: List<BigInteger>)

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
    // As tests get more complex, pass more inputs to evm and check more outputs.
    val result = evm(code["bin"].asString.hexToByteArray())
    val expectedStack = expected.getAsJsonArray("stack")?.map { parseInteger(it.asString) }
    val expectedSuccess = expected["success"].asBoolean

    if (result.success != expectedSuccess || (expectedStack != null && result.stack != expectedStack)) {
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
