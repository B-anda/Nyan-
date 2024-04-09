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
    inner_node = SyntaxTreeNode.new
    program_node = ProgramNode.new(inner_node)
  end
end

class TestAssignment < Test::Unit::TestCase
  def test_eval
    scope = GlobalScope.new
    value_node = ValueNode.new(5)
    assignment_node = Assignment.new("^3^", "monogatari", value_node)
    assert_raise(NyameNyerror.new()) {scope.findVariable("monogatari")}
    assignment_node.eval(scope)
    assert_equal( 5, scope.findVariable("monogatari"))
  end
end

class TestVariableNode < Test::Unit::TestCase
  def test_existing_variable
    scope = GlobalScope.new
    variable_node = VariableNode.new("x")
    scope.addVariable("x", 10)
    assert_equal("x", variable_node.eval(scope))
  end

  def test_nonexistent_variable
    scope = GlobalScope.new
    variable_node = VariableNode.new("y")
    assert_raise(NyameNyerror.new("y nyot found")){variable_node.eval(scope)}
  end
end

class TestValueNode < Test::Unit::TestCase
  def test_eval
    value_node = ValueNode.new(10)
    assert_equal(10, value_node.eval)
  end
end

class TestPrintNode < Test::Unit::TestCase
  def test_existing_variable
    scope = GlobalScope.new
    scope.addVariable("x", 10)
    variable_node = VariableNode.new("x")
    print_node = PrintNode.new(variable_node)
    assert_equal(10, print_node.eval(scope))
  end

  def test_value_node
    scope = GlobalScope.new
    value_node = ValueNode.new(42)
    print_node = PrintNode.new(value_node)
    assert_equal(42,  print_node.eval(scope) )
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
    assert_nil condition_node.eval(scope)
  end
end

class TestLogicStmt < Test::Unit::TestCase
  def test_not_operator
    logic_stmt = LogicStmt.new(nil, "not", ValueNode.new(false))
    assert_equal( true, logic_stmt.eval)
  end

  def test_logical_and_operator
    logic_stmt = LogicStmt.new(ValueNode.new(true), "&&", ValueNode.new(false))
    assert_equal false, logic_stmt.eval
  end

  def test_logical_or_operator
    logic_stmt = LogicStmt.new(ValueNode.new(true), "||", ValueNode.new(false))
    assert_equal true, logic_stmt.eval
  end
end

class TestValueComp < Test::Unit::TestCase
  def test_less_than_operator
    value_comp = ValueComp.new(ValueNode.new(5), "<", ValueNode.new(10))
    assert_equal( true, value_comp.eval)
  end

  def test_greater_than_operator
    value_comp = ValueComp.new(ValueNode.new(10), ">", ValueNode.new(5))
    assert_equal( true, value_comp.eval)
  end

end

class TestLogicExpr < Test::Unit::TestCase
  def test_with_value_node
    scope = GlobalScope.new
    scope.addVariable("x", 10)
    logic_expr = LogicExpr.new(ValueNode.new(10))
    assert_equal( 10, logic_expr.eval(scope))
  end

  def test_with_variable_node
    scope = GlobalScope.new
    scope.addVariable("x", ValueNode.new(10))
    logic_expr = LogicExpr.new(VariableNode.new("x"))
    assert_equal(10, logic_expr.eval(scope))
  end

  def test_nil
    scope = GlobalScope.new
    variable_node = VariableNode.new("y")
    logic_expr = LogicExpr.new(variable_node)
    assert_raise(NyameNyerror.new("Logic Canyot nyevaluate Nyariable y")) {logic_expr.eval(scope)}
  end
end
