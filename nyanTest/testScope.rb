require 'test/unit'
require "./scope"

class Test_Scopes < Test::Unit::TestCase
    def test_global_init
        globalScope = GlobalScope.new()
        current_scope = globalScope.current

        assert_nil(globalScope.prevScope)
        assert_equal(globalScope, current_scope)
    end

    def test_global_add
        global_scope = GlobalScope.new
        assert_equal global_scope, global_scope.current

        child_scope = Scope.new
        global_scope.addScope(child_scope)
        assert_equal child_scope, global_scope.current
        assert_equal global_scope, child_scope.prevScope
    end
end