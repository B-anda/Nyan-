require 'test/unit'
require './scope'
require './syntaxtree'

# class Condition_Test < Test::Unit::TestCase
#     def test_initiaize
#         conNode = ConditionNode.new(:else, )
#         conNode = ConditionNode.new(:elsis, )
#         conNode = ConditionNode.new(:if, )

#         stmt = LogicStmt.new()
#     end
        
# end

class LogicStmt_Test < Test::Unit::TestCase


    def assert_output(result, code)
        @nyan = Nyan.new 
        assert_equal(result, @nyan.nyanParser.parse(code))
    end

    def test_not
        input = "not a"
        value = ValueComp.new(5, "<", 10)
        value2 = ValueComp.new(10, "<", 4)

        # :logicStmt
        # if ^ 3 > 5 ^
        # if ^ a == 4 and b == 3 ^
        # if ^ var ^

        temp_true = LogicStmt.new("not", value2, nil)
        temp_false = LogicStmt.new("not", value, nil)

        assert(temp_true.eval())
        assert_false(temp_false.eval())
    
    end

    def test_and

    end

    def test_or

    end
end

class ValueComp_Test < Test::Unit::TestCase
    def test_greater_less
        lhs = ValueNode.new("5")
        rhs = ValueNode.new("2")

        valNode = ValueComp.new(lhs, ">", rhs)
        assert_equal(true, valNode.eval())

        valNode2 = ValueComp.new(lhs, "<", rhs)
        assert_equal(false, valNode2.eval())
    end

    def test_greater_less_equal
        lhs = ValueNode.new(5)
        rhs = ValueNode.new(2)

        test = ValueNode.new(2)

        valNode = ValueComp.new(lhs, ">=", rhs)
        assert_equal(true, valNode.eval())

        lhs1 = ValueNode.new("5")
        rhs1 = ValueNode.new("2")

        valNode2 = ValueComp.new(lhs1, "<=", rhs1)
        assert_equal(false, valNode2.eval())

        valNode3 = ValueComp.new(test, ">=", rhs)
        assert_equal(true, valNode3.eval())

        valNode4 = ValueComp.new(test, "<=", rhs)
        assert_equal(true, valNode4.eval())
    end

    def test_equal
        lhs = ValueNode.new("hello")
        rhs = ValueNode.new("hello")

        valNode = ValueComp.new(lhs, "==", rhs)
        assert_equal(true, valNode.eval())

        lhs1 = ValueNode.new(8)
        rhs1 = ValueNode.new(8)

        valNode = ValueComp.new(lhs1, "==", rhs1)
        assert_equal(true, valNode.eval())

        lhs2 = ValueNode.new(8)
        rhs2 = ValueNode.new(2)

        valNode = ValueComp.new(lhs2, "==", rhs2)
        assert_false(valNode.eval())
        
        valNode2 = ValueComp.new(lhs, "!=", rhs1)
        assert_equal(true, valNode2.eval())

        valNode2 = ValueComp.new(lhs, "!=", rhs)
        assert_false(valNode2.eval())
    end        
end

class LogicExpr_Test < Test::Unit::TestCase

    def test_initiaize
        scope = Scope.new

        tempVal = ValueNode.new(10)
        conNode = LogicExpr.new(tempVal)
        assert(conNode.eval(scope))

        tempVal1 = VariableNode.new("test")
        conNode = LogicExpr.new(tempVal1)
        assert_false(conNode.eval(scope))

        value = ValueNode.new(19)
        tempVal2 = VariableNode.new("testStr")
        scope.addVariable(tempVal2,value)

        conNode = LogicExpr.new(tempVal2)
        assert(conNode.eval(scope))
        
        boolTrue = ValueNode.new(true)
        assert(boolTrue)

        varNode = VariableNode.new("temp")
        scope.addVariable(varNode, 10)
        conNode = LogicExpr.new(varNode)
        assert(conNode.eval(scope))

    end
end