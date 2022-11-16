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

        { success: success, stack: stack }
    end
end

class EVMTest
    attr_reader :data

    def initialize
        json_file = '../evm.json'
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

            expected_stack = test['expect']['stack'] && test['expect']['stack'].map {|value| value.hex }

            if result[:stack] != expected_stack or result[:success] != test['expect']['success']
                puts "❌ Test #{i + 1}/#{total} #{test['name']}"
                if result[:stack] != expected_stack
                    puts "Stack doesn't match"
                    puts " expected:", expected_stack
                    puts "   actual:", result[:stack]
                else
                    puts "Success doesn't match"
                    puts " expected:", test['expect']['success']
                    puts "   actual:", result[:success]
                end
                puts ""
                puts "Test code:"
                puts test['code']['asm']
                puts ""
                puts "Hint:", test['hint']
                puts ""
                puts "Progress: #{i}/#{total}"
                puts ""
                break
            else
                puts "✓  Test #{i + 1}/#{total} #{test['name']}"
            end
        end
    end
end

evm_test = EVMTest.new
evm_test.run
