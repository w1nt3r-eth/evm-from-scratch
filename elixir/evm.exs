# Elixir 1.18+: run `make elixir` from the repository root.
defmodule EVM do
  def run(code), do: execute(code, 0, [])

  defp execute(code, pc, stack) when pc >= byte_size(code), do: {true, stack}

  defp execute(code, pc, stack) do
    _opcode = :binary.at(code, pc)

    # TODO: implement the EVM here!

    execute(code, pc + 1, stack)
  end

  def parse_integer("0x" <> hex), do: String.to_integer(hex, 16)
  def parse_integer(decimal), do: String.to_integer(decimal)
end

test_file = if File.exists?("../evm-pro.json"), do: "../evm-pro.json", else: "../evm.json"
tests = test_file |> File.read!() |> JSON.decode!()

total = length(tests)

tests
|> Enum.with_index()
|> Enum.each(fn {test, index} ->
  IO.puts("Test ##{index + 1}/#{total}: #{test["name"]}")
  code = Base.decode16!(test["code"]["bin"], case: :mixed)
  # As tests get more complex, pass more inputs to EVM.run and check more outputs.
  {success, stack} = EVM.run(code)

  expected_stack =
    case test["expect"]["stack"] do
      nil -> nil
      values -> Enum.map(values, &EVM.parse_integer/1)
    end

  expected_success = test["expect"]["success"]

  if success != expected_success or (expected_stack != nil and stack != expected_stack) do
    IO.puts("Expected success: #{expected_success}; got: #{success}")
    IO.puts("Expected stack: #{inspect(expected_stack, charlists: :as_lists)}")
    IO.puts("Actual stack: #{inspect(stack, charlists: :as_lists)}")
    IO.puts("Instructions:\n#{test["code"]["asm"] || test["code"]["bin"]}")
    if test["hint"], do: IO.puts("Hint: #{test["hint"]}")
    IO.puts("Progress: #{index}/#{total}")
    System.halt(1)
  end
end)

IO.puts("Progress: #{total}/#{total}")
