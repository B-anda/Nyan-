require 'test/unit'
require './scope'
require './condition'
require './syntaxtree'

class TestWhileNode < Test::Unit::TestCase
    def test_loop
        bigScope = GlobalScope.new

        int = DatatypeNode.new(:integer)
        variable = VariableNode.new('x')
        value = ValueNode.new(0)

        AssignmentNode.new(int, variable, value).eval(bigScope)

        valueComparison = ValueComp.new(LogicExpr.new(variable), "<", LogicExpr.new(ValueNode.new(5)))
        block = ReassignmentNode.new(variable, "+", ValueNode.new(1))
        
        WhileNode.new(valueComparison, block).eval(bigScope)
        
        assert_equal(5, bigScope.findVariable(variable).value)
    end
    
end