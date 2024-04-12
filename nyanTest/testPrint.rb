# require 'minitest/spec'
# require 'minitest/autorun'
require 'test/unit'
require './scope'
require './syntaxtree'
require './condition'
require './parser'

# class TestPrintNode < MiniTest::Unit::TestCase

#     def test_valueNode
#         scope = GlobalScope.new
#         valueNode = ValueNode.new(42)
#         printNode = PrintNode.new(valueNode)
        
#         assert_output(/42/) {printNode.eval(scope) } 
#     end
# end

class TestProgramNode < Test::Unit::TestCase

    def test_complex_nested_conditions 
    
        nyan = Nyan.new
        program = 
        "?nya? ^true^: 
            ?nya? ^false^: 
                meow ^\"hello\"^ 
            ?nyanye? ^true^: 
                ?nya? ^true^: 
                meow ^\"world\"^
                :3
            :3
        :3"
        puts nyan.nyanParser.parse(program)
        
        assert_equal("world", nyan.nyanParser.parse(program))
        # syntaxTree = program.eval(@current_scope)
        # puts syntaxTree
        # assert_nothing_raised do 
        #   nyan.nyanParser.parse(program)
        # end
    end
end
