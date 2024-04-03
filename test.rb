require 'test/unit'
require './syntaxtree'

class Scope_test < Test::Unit::TestCase
    def test_scope
        scope = Scope.new
        assert_equal({}, scope.vars)
        assert_nil(scope.top_node)
    end

    def test_add_var
        scope = Scope.new
        scope.add_variable("test_var", "some str")
        assert_equal("some str", scope.find_variable("test_var"))
    end

end

class TestNestedScopes < Test::Unit::TestCase
    def test_nested_scopes
        outer_scope = Scope.new
        outer_scope.add_variable("outer_var", 10)

        inner_scope = Scope.new(outer_scope)
        inner_scope.add_variable("inner_var", 20)

        assert_equal(10, outer_scope.find_variable("outer_var"))
        assert_equal(20, inner_scope.find_variable("inner_var"))

        # Accessing variable from outer scope
        assert_equal(10, inner_scope.find_variable("outer_var"))

        # Trying to access variable from inner scope in outer scope
        assert_nil(outer_scope.find_variable("inner_var"))
    end
end

class Assignment_test < Test::Unit::TestCase

    def test_initiaize
        a = Assignment.new("^w^", "hello", "world")

        assert_equal("^w^", a.datatype)
        assert_equal("hello", a.var)
        assert_equal("world", a.value)
    end

    def test_eval
        scope = Scope.new
        value = ValueNode.new("world")

        assignment = Assignment.new("^w^", "test_str", value)
        assert_equal("world", assignment.eval(scope))
        assert_equal("world", scope.find_variable("test_str"))
    end

    def test_add_var
        scope = Scope.new
        value = ValueNode.new("world")
        name = VariableNode.new("hello")

        scope.add_variable(name, value)
        assert_equal("world", scope.find_variable("hello"))
        
    end
        

end

class Datatype_Test < Test::Unit::TestCase
    def test_initiaize
        datatype = DatatypeNode.new("^w^")
        assert_equal("^w^", datatype.datatype)
    end
end


