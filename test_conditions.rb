require 'test/unit'
require './scope'
require './syntaxtree'

# class Condition_Test < Test::Unit::TestCase
#     def test_initiaize
#         conNode = ConditionNode.new(:else, )
#     end
        
# end

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
        conNode = LogicExpr.new("true")
        assert_equal(true, conNode.eval())

        conNode = LogicExpr.new("false")
        assert_equal(false, conNode.eval())
    end
        
end