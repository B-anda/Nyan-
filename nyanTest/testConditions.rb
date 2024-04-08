require 'test/unit'
require './scope'
require './nyan'

class TestParsingAndEvaluation < Test::Unit::TestCase
  def setup
    @scope = GlobalScope.new
    @current_scope = @scope.current
  end

  def test_parse_and_evaluate_program_with_simple_condition
    nyan = Nyan.new
    program = nyan.nyanParser.parse("?nya? ^true^: meow ^1^; :3") # 'true' is currently matched as a part of the variable rule
    syntax_tree = program.eval(@current_scope)

    # Ver?nya?y that syntax tree contains the expected nodes
    assert_equal 1, syntax_tree.nodes.length
    assert_instance_of ConditionNode, syntax_tree.nodes[0]
    
    # Execute the condition and ver?nya?y output
    assert_output("1\n") { syntax_tree.nodes[0].eval(@current_scope) }
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

#     # Ver?nya?y that syntax tree contains the expected nodes
#     assert_equal( 1, syntax_tree.nodes.length)
#     assert_instance_of( ConditionNode, syntax_tree.nodes[0])
#     assert_equal( 1, syntax_tree.nodes[0].block.nodes.length)
#     assert_instance_of( ConditionNode, syntax_tree.nodes[0].block.nodes[0])
#     assert_equal( 1, syntax_tree.nodes[0].block.nodes[0].condition.block.nodes.length)
#     assert_instance_of( ConditionNode, syntax_tree.nodes[0].block.nodes[0].condition.block.nodes[0])
    
#     # Execute nested conditions and ver?nya?y output
#     assert_output("2\n") { syntax_tree.nodes[0].block.nodes[0].condition.block.nodes[0].eval(@current_scope) }
#   end

#   def test_complex_logical_expressions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse(
#         "int x = 10
#          ?nya? ^(x > 5 && x < 15) || x == 20^: 
#             meow ^true^
#         :3")
#     syntax_tree = program.eval(@current_scope)

#     # Ver?nya?y that syntax tree contains the expected nodes
#     assert_equal (2, syntax_tree.nodes.length)
    
#     assert_output("true\n") { syntax_tree.nodes[1].eval(@current_scope) }
#   end

#   def test_printing_complex_expressions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse("int x = 10; meow ^(x > 5 && x < 15) || x == 20^;")
#     syntax_tree = program.eval(@current_scope)

#     assert_equal 2, syntax_tree.nodes.length
    
#     assert_output("true\n") { syntax_tree.nodes[1].eval(@current_scope) }
#   end
end