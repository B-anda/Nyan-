require 'test/unit'
require './scope'
require './syntaxtree'
require './parser'

class TestSyntaxTreeNode < Test::Unit::TestCase
  def test_eval
    node = SyntaxTreeNode.new
    assert_raise(NoMethodError) { node.eval }
  end
end

class TestProgramNode < Test::Unit::TestCase
  def test_eval
    inner_node = SyntaxTreeNode.new
    program_node = ProgramNode.new(inner_node)
    #assert_nothing_raised { program_node.eval }
  end
end

class TestAssignment < Test::Unit::TestCase
  def test_eval
    scope = Scope.new
    value_node = ValueNode.new(5)
    assignment_node = Assignment.new("^3^", "x", value_node)
    assert_nothing_raised { assignment_node.eval(scope) }
    assert_equal( 5, scope.findVariable("x"))
  end
end

class TestVariableNode < Test::Unit::TestCase
  def test_eval_existing_variable
    scope = Scope.new
    variable_node = VariableNode.new("x")
    scope.addVariable("x", 10)
    assert_equal("x", variable_node.eval(scope))
  end

  def test_eval_nonexistent_variable
    scope = Scope.new
    variable_node = VariableNode.new("y")
    assert_nil(variable_node.eval(scope))
  end
end

class TestValueNode < Test::Unit::TestCase
  def test_eval
    value_node = ValueNode.new(10)
    assert_equal(10, value_node.eval)
  end
end

class TestPrintNode < Test::Unit::TestCase
  def test_eval_existing_variable
    scope = Scope.new
    scope.addVariable("x", 10)
    variable_node = VariableNode.new("x")
    print_node = PrintNode.new(variable_node)
    assert_equal(10, print_node.eval(scope))
  end

  def test_eval_value_node
    scope = Scope.new
    value_node = ValueNode.new(42)
    print_node = PrintNode.new(value_node)
    assert_equal(42,  print_node.eval(scope).value )
  end
end

class TestConditionNode < Test::Unit::TestCase
  def test_eval_if_true
    scope = Scope.new
    condition_node = ConditionNode.new(:if, ValueNode.new(true), ValueNode.new("true"))
    assert_equal(true, condition_node.eval(scope) )
  end

  def test_eval_if_false
    scope = Scope.new
    condition_node = ConditionNode.new(:if, ValueNode.new(false), ValueNode.new("true"))
    assert_nil condition_node.eval(scope)
  end
end

class TestLogicStmt < Test::Unit::TestCase
  def test_eval_not_operator
    logic_stmt = LogicStmt.new(nil, "not", ValueNode.new(false))
    assert_equal( true, logic_stmt.eval)
  end

  def test_eval_logical_and_operator
    logic_stmt = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(false))
    assert_equal false, logic_stmt.eval
  end

  def test_eval_logical_or_operator
    logic_stmt = LogicStmt.new(ValueNode.new(true), "||", ValueNode.new(false))
    assert_equal true, logic_stmt.eval
  end
end

class TestValueComp < Test::Unit::TestCase
  def test_eval_less_than_operator
    value_comp = ValueComp.new(ValueNode.new(5), "<", ValueNode.new(10))
    assert_equal( true, value_comp.eval)
  end

  def test_eval_greater_than_operator
    value_comp = ValueComp.new(ValueNode.new(10), ">", ValueNode.new(5))
    assert_equal( true, value_comp.eval)
  end

end

class TestLogicExpr < Test::Unit::TestCase
  def test_eval_with_value_node
    scope = Scope.new
    scope.addVariable("x", 10)
    logic_expr = LogicExpr.new(ValueNode.new(10))
    assert_equal( 10, logic_expr.eval(scope))
  end

  def test_eval_with_variable_node
    scope = Scope.new
    scope.addVariable("x", ValueNode.new(10))
    logic_expr = LogicExpr.new(VariableNode.new("x"))
    assert_equal(10, logic_expr.eval(scope))
  end

  def test_eval_nil
    scope = Scope.new
    variable_node = VariableNode.new("y")
    logic_expr = LogicExpr.new(variable_node)
    assert_nil( logic_expr.eval(scope))
  end
end
