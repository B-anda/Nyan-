require 'test/unit'
require './errors'
require './scope'
require './syntaxtree'

class Test_Scopes < Test::Unit::TestCase

    def test_global_init

        globalScope = GlobalScope.new()
        currentScope = globalScope.current

        assert_nil(globalScope.prevScope)
        assert_equal(globalScope, currentScope)
    end

    
    def test_global_add

        conditionScope = GlobalScope.new
        conditionScope.addScope(conditionScope)

        assert(conditionScope.scopes)
        assert_false(conditionScope.current == conditionScope)
        assert_empty(conditionScope.vars)
        assert_empty(conditionScope.current.vars)
        assert_equal(conditionScope.current.prevScope, conditionScope)
        conditionScope.currToPrevScope
        assert_equal(conditionScope, conditionScope.current)
        assert_raise(NyantimeNyerror.new()) {conditionScope.currToPrevScope}
    end


    def test_nested_scopes

        conditionScope = GlobalScope.new
        variable = VariableNode.new("big")
        value = ValueNode.new("small") 
        conditionScope.addScope(conditionScope.current)
        conditionScope.current.addVariable(variable, value)
        conditionScope.currToPrevScope()
        conditionScope.addScope(conditionScope.current)

        assert_equal(conditionScope.scopes.size, 2)
        assert_equal(conditionScope.current, conditionScope.scopes[1])
        assert_equal(conditionScope.scopes[0].findVariable("big"), value)
        assert_raise(NyameNyerror.new("#{variable} nyot found")) {conditionScope.current.findVariable(variable)}
    end
end