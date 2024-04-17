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

## Testing class: Assignment ##

class TestAssignment < Test::Unit::TestCase

  def test_eval
    scope = GlobalScope.new
    valueNode = ValueNode.new(5)
    assignmentNode = AssignmentNode.new("^3^", "monogatari", valueNode)
    assert_raise(NyameNyerror.new()) {scope.findVariable("monogatari")}
    assignmentNode.eval(scope)
    assert_equal( valueNode, scope.findVariable("monogatari"))
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
  end

end

## Testing class: PrintNode ##

class TestPrintNode < Test::Unit::TestCase

  def test_existing_variable
    scope = GlobalScope.new
    scope.addVariable("x", ValueNode.new(10))
    variableNode = VariableNode.new("x")
    printNode = PrintNode.new(variableNode)

    assert_equal(10, printNode.eval(scope))

    valueNode = ValueNode.new(10)
    printNode2 = PrintNode.new(valueNode)

    # assert_equal(10, printNode2.eval(scope))
  end

  def test_valueNode
    scope = GlobalScope.new
    valueNode = ValueNode.new(42)
    printNode = PrintNode.new(valueNode)
    # assert_output(42) {printNode.eval(scope) } 
  end

end

## Testing class: ArithmeticNode

class TestArithmeticNode < Test::Unit::TestCase

  def test_add_sub

    scope = GlobalScope.new
    val1 = ValueNode.new(2)
    val2 = ValueNode.new(4)

    sum = ArithmaticNode.new(val1, "+", val2)
    assert_equal(6, sum.eval)

    sum2 = ArithmaticNode.new(val1, "-", val2)
    assert_equal(-2, sum2.eval)

    # Tesing with variableNodes
    varNode = VariableNode.new("add")
    scope.addVariable(varNode, val1)
    
    sum3 = ArithmaticNode.new(varNode, "+", val2)
    assert_equal(6, sum3.eval(scope))

    sum4 = ArithmaticNode.new(varNode, "+", varNode)
    assert_equal(4, sum4.eval(scope))
  end

  def test_mult

    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)

    sum_mult = ArithmaticNode.new(val1, "*", val2)
    assert_equal(50, sum_mult.eval)

    sum_mult2 = ArithmaticNode.new(val2, "*", val4)
    assert_equal(0, sum_mult2.eval)

    sum_mult3 = ArithmaticNode.new(val2, "*", val3)
    assert_equal(12.5, sum_mult3.eval)

  end

  def test_div

    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)
    val5 = ValueNode.new(2)

    sum_div = ArithmaticNode.new(val1, "/", val2)
    assert_equal(2, sum_div.eval)

    sum_div2 = ArithmaticNode.new(val2, "//", val5)
    assert_equal(2, sum_div2.eval)

    sum_div2 = ArithmaticNode.new(val1, "/", val4) #hantera ZerodivisionError
    #assert_raise(NyanZeroNyerror.new()) {sum_div2.eval}

  end

  def test_complex_arithmatics
    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)

    nyan = Nyan.new
    program = nyan.nyanParser.parse(
      "2+6-4"  
    ) 
    assert_equal(4, program)

    program2 = nyan.nyanParser.parse(
      "2+6*4"  
    ) 
    assert_equal(26, program2)

    program3 = nyan.nyanParser.parse(
      "(5*2)*8+(4-2)"  
    ) 
    assert_equal(82, program3)

    program4 = nyan.nyanParser.parse(
      "5 / 2"  
    ) 
    assert_equal(2.5, program4)

    program5 = nyan.nyanParser.parse(
      "5 // 2"  
    ) 
    assert_equal(2, program5)

    program5 = nyan.nyanParser.parse(
      "5 % 2"  
    ) 
    assert_equal(1, program5) 
  end
end