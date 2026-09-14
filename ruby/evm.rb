# EVM From Scratch
# Ruby template
#
# To work on EVM From Scratch in Ruby:
#
# - Install Ruby: https://www.ruby-lang.org/en/downloads/
# - Go to the `ruby` directory: `cd ruby`
# - Edit `evm.rb` (this file!), see TODO below
# - Run `ruby evm.rb` to run the tests

require 'json'

class EVM
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def run
    pc = 0
    success = true
    stack = []

    while pc < code.length
      op = code[pc]
      pc += 1

      # TODO: implement the EVM here!

    end

    { success: success, stack: stack, return: '', logs: [], state: {} }
  end
end

class EVMTest
  attr_reader :data

  def initialize
    json_file = File.expand_path('../evm-pro.json', __dir__)
    json_file = File.expand_path('../evm.json', __dir__) unless File.exist?(json_file)
    file = File.read(json_file)

    @data = JSON.parse(file)
  end

  def total
    data.length
  end

  def run
    data.each_with_index do |test, i|
      hex_code = test['code']['bin']
      code = hex_code.scan(/../).map(&:hex)

      # Note: as the test cases get more complex, you'll need to modify this
      # to pass down more arguments to the evm class
      evm = EVM.new(code)

      result = evm.run

      mismatches = test['expect'].map do |field, expected|
        next if expected.nil?
        expected = expected.map { |value| value.hex } if field == 'stack'
        actual = result[field.to_sym]
        [field, expected, actual] unless actual == expected
      end.compact

      unless mismatches.empty?
        puts "❌ Test #{i + 1}/#{total} #{test['name']}"
        mismatches.each do |field, expected, actual|
          puts "#{field} doesn't match"
          p expected: expected, actual: actual
        end
        puts ""
        puts "Test code:"
        puts test['code']['asm'] || test['code']['bin']
        puts ""
        puts "Hint:", test['hint']
        puts ""
        puts "Progress: #{i}/#{total}"
        puts ""
        exit 1
      else
        puts "✓  Test #{i + 1}/#{total} #{test['name']}"
      end
    end
  end
end

evm_test = EVMTest.new
evm_test.run
