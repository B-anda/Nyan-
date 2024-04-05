require 'test/unit'
require './scope'
require './syntaxtree'
require './parser'

class Condition_Test < Test::Unit::TestCase
    def assert_output(result, code)
        @nyan = Nyan.new 
        assert_equal(result, @nyan.nyanParser.parse(code))
    end

    def test_initiaize
        # conNode = ConditionNode.new(:else, )
        # conNode = ConditionNode.new(:elsis, )
        scope = Scope.new

        block = PrintNode.new("hello")

        greater = ValueNode.new(10)
        lesser = ValueNode.new(2)

        stmt = ValueComp.new(lesser, "<", greater)
        conNode = ConditionNode.new(:if, stmt, block)

        assert_equal("hello", conNode.eval(scope))
        # assert_output("hello", "?nya? ^ 5 > 2 ^ : meow ^\"hello\"^ :3")
    end
        
end

class LogicStmt_Test < Test::Unit::TestCase

    def test_not
        scope = Scope.new

        greater = ValueNode.new(10)
        lesser = ValueNode.new(2)

        value = ValueComp.new(lesser, "<", greater)
        value2 = ValueComp.new(greater, "<", lesser)

        checkTrue = LogicStmt.new(nil, "not", value2)
        checkFalse = LogicStmt.new(nil, "not", value)

        assert(checkTrue.eval())
        assert_false(checkFalse.eval())

        val = ValueNode.new(42)
        expr1 = LogicExpr.new(val)

        checkFalse = LogicStmt.new(nil, "not", expr1)
        assert_false(checkFalse.eval())
    end

    def test_and
        scope = Scope.new

        #TEST :valueComp "&&" :valueComp
        greater = ValueNode.new(10)
        lesser = ValueNode.new(2)

        value1 = ValueComp.new(lesser, "<", greater)
        value2 = ValueComp.new(greater, ">", lesser)

        checkTrue = LogicStmt.new(value1, "&&", value2)
        assert(checkTrue.eval())

        #TEST :logicExpr "&&" :LogicExpr
        val = ValueNode.new(42)
        expr1 = LogicExpr.new(val)
        
        varNode = VariableNode.new("temp")
        scope.addVariable(varNode, 10)
        expr2 = LogicExpr.new(varNode)

        toBeOrNotToBe2 = LogicStmt.new(expr1, "&&", expr2)
        assert(toBeOrNotToBe2.eval(scope))

        #TEST :logicExpr "&&" :logicExpr
        toBeOrNotToBe3 = LogicStmt.new(value1, "&&", expr1)
        assert(toBeOrNotToBe3.eval(scope))
    end

    def test_or
        scope = Scope.new

        greater = ValueNode.new(10)
        lesser = ValueNode.new(2)

        value1 = ValueComp.new(lesser, "<", greater)
        value2 = ValueComp.new(greater, ">", lesser)

        checkTrue = LogicStmt.new(value1, "||", value2)
        assert(checkTrue.eval())
    end
end

class ValueCompTest < Test::Unit::TestCase
    def assert_output(result, code)
        @nyan = Nyan.new 
        assert_equal(result, @nyan.nyanParser.parse(code))
    end

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

        # assert_output(true, "10 == 10")
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