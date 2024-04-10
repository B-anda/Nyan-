require 'test/unit'
require './scope'
require './syntaxtree'
require './condition'
require './parser'

class TestSyntaxTreeNode < Test::Unit::TestCase
  def test_eval
    node = SyntaxTreeNode.new
    assert_raise(NoMethodError) { node.eval }
  end
end

class TestProgramNode < Test::Unit::TestCase
  def test_eval
    innerNode = SyntaxTreeNode.new
    programNode = ProgramNode.new(innerNode)
  end
end

class TestAssignment < Test::Unit::TestCase
  def test_eval
    scope = GlobalScope.new
    valueNode = ValueNode.new(5)
    assignmentNode = Assignment.new("^3^", "monogatari", valueNode)
    assert_raise(NyameNyerror.new()) {scope.findVariable("monogatari")}
    assignmentNode.eval(scope)
    assert_equal( 5, scope.findVariable("monogatari"))
  end
end

class TestVariableNode < Test::Unit::TestCase
  def test_existing_variable
    scope = GlobalScope.new
    variableNode = VariableNode.new("x")
    scope.addVariable("x", 10)
    assert_equal("x", variableNode.eval(scope))
  end

  def test_nonexistent_variable
    scope = GlobalScope.new
    variableNode = VariableNode.new("y")
    assert_raise(NyameNyerror.new("y nyot found")){variableNode.eval(scope)}
  end
end

class TestValueNode < Test::Unit::TestCase
  def test_eval
    valueNode = ValueNode.new(10)
    assert_equal(10, valueNode.eval)
  end
end

class TestPrintNode < Test::Unit::TestCase
  def test_existing_variable
    scope = GlobalScope.new
    scope.addVariable("x", 10)
    variableNode = VariableNode.new("x")
    printNode = PrintNode.new(variableNode)

    assert_equal(10, printNode.eval(scope))

    valueNode = ValueNode.new(10)
    printNode2 = PrintNode.new(valueNode)

    assert_equal(10, printNode2.eval(scope))
  end

  def test_valueNode
    scope = GlobalScope.new
    valueNode = ValueNode.new(42)
    printNode = PrintNode.new(valueNode)
    assert_equal(42,  printNode.eval(scope) )
  end
end

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

class TestLogicStmt < Test::Unit::TestCase
  def test_not_operator
    logicStmt = LogicStmt.new(nil, "not", ValueNode.new(false))
    assert_equal( true, logicStmt.eval)
  end

  def test_logical_and_operator
    logicStmt = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(false))
    assert_equal false, logicStmt.eval
  end

  def test_logical_or_operator
    logicStmt = LogicStmt.new(ValueNode.new(true), "||", ValueNode.new(false))
    assert_equal true, logicStmt.eval
  end
end

class TestValueComp < Test::Unit::TestCase
  def test_less_than_operator
    valueComp = ValueComp.new(ValueNode.new(5), "<", ValueNode.new(10))
    assert_equal( true, valueComp.eval)
  end

  def test_greater_than_operator
    valueComp = ValueComp.new(ValueNode.new(10), ">", ValueNode.new(5))
    assert_equal( true, valueComp.eval)
  end

end

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
    assert_equal(10, logicExpr.eval(scope))
  end

  def test_nil
    scope = GlobalScope.new
    variableNode = VariableNode.new("y")
    logicExpr = LogicExpr.new(variableNode)
    assert_raise(NyameNyerror.new("Logic Canyot nyevaluate Nyariable y")) {logicExpr.eval(scope)}
  end
end
