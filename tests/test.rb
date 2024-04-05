require 'test/unit'
require './scope'
require './syntaxtree'

class Scope_test < Test::Unit::TestCase
    def test_scope
        scope = Scope.new
        assert_equal({}, scope.vars)
        assert_nil(scope.prevScope)
    end

    def test_add_var
        scope = Scope.new
        scope.addVariable("test_var", "some str")
        assert_equal("some str", scope.findVariable("test_var"))
    end
end

class TestNestedScopes < Test::Unit::TestCase
    def test_nested_scopes
        outerScope = GlobalScope.new
        outerScope.addVariable("outer_var", 10)

        outerScope.addScope(outerScope.current)
        outerScope.current.addVariable("inner_var", 20)

        assert_equal(10, outerScope.findVariable("outer_var"))
        assert_equal(outerScope.findVariable("outer_var"), outerScope.current.findVariable("outer_var"))
        assert_equal(20, outerScope.current.findVariable("inner_var"))

        # Accessing variable from outer scope
        assert_equal(10, outerScope.current.findVariable("outer_var"))

        # Trying to access variable from inner scope in outer scope
        assert_nil(outerScope.findVariable("inner_var"))
    end
end

class Assignment_test < Test::Unit::TestCase

    def test_initiaize
        scope = Scope.new
        a = Assignment.new("^w^", "hello", "world", scope)

        assert_equal("^w^", a.datatype)
        assert_equal("hello", a.var)
        assert_equal("world", a.value)
    end

    def test_eval
        scope = Scope.new
        value = ValueNode.new("world")

        assignment = Assignment.new("^w^", "test_str", value, scope)
        assert_equal("world", assignment.eval())
        assert_equal("world", scope.findVariable("test_str"))
    end

    def test_add_var
        scope = Scope.new
        value = ValueNode.new("world")
        name = VariableNode.new("hello", scope)
        scope.addVariable(name, value)
        assert_equal("world", scope.findVariable("hello").value)
        
    end
end

class Datatype_Test < Test::Unit::TestCase
    def test_initiaize
        datatype = DatatypeNode.new("^w^")
        assert_equal("^w^", datatype.datatype)
    end
end

class PrintNode_Test < Test::Unit::TestCase
    def test_eval
        scope = Scope.new
        str = ValueNode.new("hello")
        p = PrintNode.new(str, scope)
        assert_equal("hello", p.eval)
        puts p.eval
    end
end


