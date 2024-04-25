require 'test/unit'
require './scope'
require './parser'

class Test_Function < Test::Unit::TestCase
    def test_basic_function
        scope = GlobalScope.new()
        name = VariableNode.new("test")
        printName = ValueNode.new("Helloo")

        printObj = PrintNode.new(printName)
        func = FunctionNode.new(name, printObj, nil).eval(scope)

        assert_equal("Helloo", FunctionCall.new(name, nil).eval(scope))
    
    end

    def test_func_params
        scope = GlobalScope.new()

        param = VariableNode.new("y")
        funcName = VariableNode.new("test")

        variableNode = VariableNode.new("x")
        scope.addVariable(variableNode, 10)

        printName = ValueNode.new("Helloo")

        printObj = PrintNode.new(printName)
        func = FunctionNode.new(funcName, printObj, param).eval(scope)

        assert_equal("Helloo", FunctionCall.new(funcName, ParamsNode.new(variableNode)).eval(scope))
    end

    def test_func_multiple_params
        scope = GlobalScope.new()

        param = VariableNode.new("p1")
        param2 = VariableNode.new("p2")

        funcName = VariableNode.new("test")

        variableNode = VariableNode.new("x")
        scope.addVariable(variableNode, ValueNode.new(10))
        variableNode2 = VariableNode.new("y")
        scope.addVariable(variableNode2, ValueNode.new(20))

        # printName = ValueNode.new("Helloo")

        printObj = PrintNode.new(variableNode2)

        func = FunctionNode.new(funcName, printObj, ParamsNode.new(ParamsNode.new(param), param2)).eval(scope)

        assert_equal(20, FunctionCall.new(funcName, ParamsNode.new(ParamsNode.new(variableNode), variableNode2)).eval(scope))
    end
end
