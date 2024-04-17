require 'test/unit'
require './scope'
require './condition'
require './syntaxtree'

## Testing class: ConditionNode ##

class TestConditionNode < Test::Unit::TestCase

  def test_if_true
    scope = GlobalScope.new
    condition_node = ConditionNode.new(:if, ValueNode.new(true), ValueNode.new("true"))
    assert_equal(true, condition_node.eval(scope) )
  end

  def test_if_false
    scope = GlobalScope.new
    condition_node = ConditionNode.new(:if, ValueNode.new(false), ValueNode.new("true"))
    assert_nil(condition_node.eval(scope))
  end

end

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
