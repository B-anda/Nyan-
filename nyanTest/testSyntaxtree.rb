require 'test/unit'
require './scope'
require './syntaxtree'
require './condition'
require './parser'

## Testing class: SyntaxTreeNode ##

class TestSyntaxTreeNode < Test::Unit::TestCase

  def test_eval
    node = SyntaxTreeNode.new
    assert_raise(NoMethodError) { node.eval }
  end

end

## Testing class: ProgramNode ##

class TestProgramNode < Test::Unit::TestCase

  def test_eval
    innerNode = SyntaxTreeNode.new
    programNode = ProgramNode.new(innerNode)
  end

end

## Testing class: BlocksNode ##

class TestBlocksNode < Test::Unit::TestCase
  def test_blocks
    scope = GlobalScope.new
    valueNode = ValueNode.new(5)
    varNode = VariableNode.new("monogatari")
    assignmentNode = AssignmentNode.new("^3^", varNode, valueNode)
    
    block = BlocksNode.new(assignmentNode, ReassignmentNode.new(varNode, "=", ValueNode.new(2) ))
    block.eval(scope)
    assert_equal(2, scope.findVariable(varNode).eval)    
  end

  def test_nested_blockNodes
    scope = GlobalScope.new

    valueNode = ValueNode.new(5)
    varNode = VariableNode.new("monogatari")
    assignmentNode = AssignmentNode.new("^3^", varNode, valueNode)
    
    block = BlocksNode.new(assignmentNode, ReassignmentNode.new(varNode, "=", ValueNode.new(2)))
    block2 = BlocksNode.new(block, ReassignmentNode.new(varNode, "+", ValueNode.new(2)))
    block2.eval(scope)
    assert_equal(4, scope.findVariable(varNode).eval) 
  end

  def test_nested_blocks
    scope = GlobalScope.new

    valueNode = ValueNode.new(5)
    newValue = ValueNode.new(2)

    varNode = VariableNode.new("monogatari")

    assignmentNode = AssignmentNode.new("^3^", varNode, valueNode)
    assignmentNode2 = AssignmentNode.new("^3^", varNode, newValue)
    conditionNode = ConditionNode.new(ValueNode.new(true), assignmentNode2)
    
    block = BlocksNode.new(assignmentNode, conditionNode)
    block.eval(scope.current)

    assert_equal(scope, scope.current)
    assert_equal(5, scope.current.findVariable(varNode).eval)

  end
end

## Testing class: AssignmentNode ##

class TestAssignment < Test::Unit::TestCase

  def test_eval
    scope = GlobalScope.new
    valueNode = ValueNode.new(5)
    varNode = VariableNode.new("monogatari")
    assignmentNode = AssignmentNode.new("^3^", varNode, valueNode)
    assert_raise(NyameNyerror.new()) {scope.findVariable(varNode)}
    assignmentNode.eval(scope)
    assert_equal( valueNode, scope.findVariable(varNode))
  end

end

## Testing class: Reassignment ##

class TestRessignment < Test::Unit::TestCase
  
  
  def test_eval
  
    scope = GlobalScope.new
    variableNode = VariableNode.new("x")
    scope.addVariable(variableNode, ValueNode.new(10))

    reassign = ReassignmentNode.new(variableNode, "+", ValueNode.new(1)).eval(scope)
    assert_equal(11, reassign.eval(scope))
  
    reassign1 = ReassignmentNode.new(variableNode, "-", ValueNode.new(1)).eval(scope)
    assert_equal(10, reassign1.eval(scope))
  
    reassign2 = ReassignmentNode.new(variableNode, "=", ValueNode.new(1)).eval(scope)
    assert_equal(1, reassign2.eval(scope))
  
  end
end

## Testing class: VariableNode ##

class TestVariableNode < Test::Unit::TestCase

  
  def test_existing_variable
  
    scope = GlobalScope.new
    variableNode = VariableNode.new("x")
    scope.addVariable(variableNode, 10)
    assert_equal("x", variableNode.eval(scope))
  end

  def test_nonexistent_variable
    scope = GlobalScope.new
    variableNode = VariableNode.new("y")
    assert_raise(NyameNyerror.new("y nyot found")){variableNode.eval(scope)}
  end

end

## Testing class: ValueNode ##

class TestValueNode < Test::Unit::TestCase

  def test_eval
    valueNode = ValueNode.new(10)
    assert_equal(10, valueNode.eval)

    valueNode2 = ValueNode.new("hello")
    assert_equal("hello", valueNode2.eval)

    valueNode3 = ValueNode.new(true)
    assert_equal(true, valueNode3.eval)
  end

end

## Testing class: PrintNode ##

class TestPrintNode < Test::Unit::TestCase

  def test_existing_variable
    scope = GlobalScope.new
    variableNode = VariableNode.new("x")
    scope.addVariable(variableNode, ValueNode.new(10))
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
    assert_equal(42, printNode.eval(scope))
  end

end

## Testing class: ArithmeticNode

class TestArithmeticNode < Test::Unit::TestCase

  def test_add_sub

    scope = GlobalScope.new
    val1 = ValueNode.new(2)
    val2 = ValueNode.new(4)

    sum = ArithmaticNode.new(val1, "+", val2)
    assert_equal(6, sum.eval.value)

    sum2 = ArithmaticNode.new(val1, "-", val2)
    assert_equal(-2, sum2.eval.value)

    # Tesing with variableNodes
    varNode = VariableNode.new("add")
    scope.addVariable(varNode, val1)
    
    sum3 = ArithmaticNode.new(varNode, "+", val2)
    assert_equal(6, sum3.eval(scope).value)

    sum4 = ArithmaticNode.new(varNode, "+", varNode)
    assert_equal(4, sum4.eval(scope).value)
  end

  def test_mult

    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)

    sum_mult = ArithmaticNode.new(val1, "*", val2)
    assert_equal(50, sum_mult.eval.value)

    sum_mult2 = ArithmaticNode.new(val2, "*", val4)
    assert_equal(0, sum_mult2.eval.value)

    sum_mult3 = ArithmaticNode.new(val2, "*", val3)
    assert_equal(12.5, sum_mult3.eval.value)

  end

  def test_div

    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)
    val5 = ValueNode.new(2)

    sum_div = ArithmaticNode.new(val1, "/", val2)
    assert_equal(2, sum_div.eval.value)

    sum_div2 = ArithmaticNode.new(val2, "//", val5)
    assert_equal(2, sum_div2.eval.value)

    sum_div2 = ArithmaticNode.new(val1, "/", val4) #hantera ZerodivisionError
    #assert_raise(NyanZeroNyerror.new()) {sum_div2.eval}

  end
end

