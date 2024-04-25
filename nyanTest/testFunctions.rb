require 'test/unit'
require './scope'
require './parser'

class Test_Function < Test::Unit::TestCase

    def test_basic_function
        nyan = Nyan.new
        nyan.nyanParser.parse(
          '?nya? ^true^: 
            meow ^"hello"^
          :3' 
        ) 
    end
end
