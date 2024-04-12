require 'test/unit'
require './scope'
require './parser'

## Testing class: LogicStmt ##

class TestLogicStmt < Test::Unit::TestCase

  def test_not_operator
    logicStmt = LogicStmt.new(nil, "not", ValueNode.new(false))
    assert_equal( true, logicStmt.eval)
  end

  def test_logical_and_operator
    logicStmt = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(false))
    assert_equal(false, logicStmt.eval)
  end

  def test_logical_or_operator
    logicStmt = LogicStmt.new(ValueNode.new(true), "||", ValueNode.new(false))
    assert_equal(true, logicStmt.eval)
  end

  def test_logical_and_or
    logicStmtTrue = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(true))
    valueComp = ValueComp.new(ValueNode.new(10), ">", ValueNode.new(5))

    logicStmt = LogicStmt.new(logicStmtTrue, "||", valueComp)
    assert_equal(true, logicStmt.eval)

    logicStmtTrue = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(false))
    logicExpr = LogicExpr.new(ValueNode.new(true))
    logicStmt2 = LogicStmt.new(logicStmtTrue, "||", logicExpr)

    assert_equal(true, logicStmt2.eval)

  end

end

## Testing class: ValueComp ##

class TestValueComp < Test::Unit::TestCase

  def test_less_than_operator
    valueComp = ValueComp.new(ValueNode.new(5), "<", ValueNode.new(10))
    assert_equal( true, valueComp.eval)

    scope = GlobalScope.new
    variableNode = VariableNode.new("x")
    logicExpr = LogicExpr.new(variableNode)
    scope.addVariable(variableNode, 10)
    
    valueComp = ValueComp.new(ValueNode.new(5), "<", logicExpr)
    assert_equal( true, valueComp.eval(scope))
  end

  def test_greater_than_operator
    valueComp = ValueComp.new(ValueNode.new(10), ">", ValueNode.new(5))
    assert_equal( true, valueComp.eval)
  end

end

## Testing class: LogicExpr ##

class TestLogicExpr < Test::Unit::TestCase

  def test_with_valueNode
    scope = GlobalScope.new
    scope.addVariable("x", 10)
    logicExpr = LogicExpr.new(ValueNode.new(10))
    assert_equal( 10, logicExpr.eval(scope))
  end

  def test_with_variable_node
    scope = GlobalScope.new
    scope.addVariable("x", ValueNode.new(10))
    logicExpr = LogicExpr.new(VariableNode.new("x"))
    assert_equal(10, logicExpr.eval(scope).value)
  end

  def test_nil
    scope = GlobalScope.new
    variableNode = VariableNode.new("y")
    logicExpr = LogicExpr.new(variableNode)
    assert_raise(NyameNyerror.new("Logic Canyot nyevaluate Nyariable y")) {logicExpr.eval(scope)}
  end

end

## Testing : Parsing nyan conditions through the parser ##

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

  def test_parse_and_or
    nyan = Nyan.new
      program = nyan.nyanParser.parse(
        "?nya? ^ true|| false ^: 
          meow ^\"hello\"^
        :3"  
      ) 
  
      assert_equal("hello", program)
  end

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

    #assert_equal("world", nyan.nyanParser.parse(program))
    # syntaxTree = program.eval(@current_scope)
    # puts syntaxTree
    assert_nothing_raised do 
      nyan.nyanParser.parse(program)
    end
  end

  # def test_complex_logical_expressions
  #   nyan = Nyan.new
  #   program = nyan.nyanParser.parse(
  #       "int x = 10
  #        ?nya? ^(x > 5 && x < 15) || x == 20^: 
  #           meow ^true^
  #       :3")
  #   syntax_tree = program.eval(@current_scope)
  # end

#   def test_printing_complex_expressions
#     nyan = Nyan.new
#     program = nyan.nyanParser.parse("int x = 10; meow ^(x > 5 && x < 15) || x == 20^;")
#     syntax_tree = program.eval(@current_scope)

#     assert_equal 2, syntax_tree.scopes.length
    
#     assert_output("true\n") { syntax_tree.scopes[1].eval(@current_scope) }
#   end
end