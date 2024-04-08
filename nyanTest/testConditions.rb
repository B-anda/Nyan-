require 'test/unit'
require './scope'
require './nyan'

class Test_ParsingAndEvaluation < Test::Unit::TestCase

  def test_simple_condition
    nyan = Nyan.new
    program = nyan.nyanParser.parse(
      "?nya? ^true^: 
        meow ^\"hello\"^
      :3"  
    ) 

    assert_equal("hello", program)

  end

#   def test_complex_nested_conditions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse(
#         "?nya? ^true^: 
#             ?nya? ^false^: 
#                 meow ^1^ 
#             ?nyanye?: 
#                 ?nya? ^true^: 
#                     meow ^2^
#                 :3
#             :3")
#     syntax_tree = program.eval(@current_scope)
#   end
#   def test_complex_logical_expressions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse(
#         "int x = 10
#          ?nya? ^(x > 5 && x < 15) || x == 20^: 
#             meow ^true^
#         :3")
#     syntax_tree = program.eval(@current_scope)
#   end

#   def test_printing_complex_expressions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse("int x = 10; meow ^(x > 5 && x < 15) || x == 20^;")
#     syntax_tree = program.eval(@current_scope)

#     assert_equal 2, syntax_tree.scopes.length
    
#     assert_output("true\n") { syntax_tree.scopes[1].eval(@current_scope) }
#   end
end