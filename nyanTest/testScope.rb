require 'test/unit'
require "./scope"

class Test_Scopes < Test::Unit::TestCase
    def test_global_init
        globalScope = GlobalScope.new()
        current_scope = globalScope.current

        assert_nil(globalScope.prevScope)
        assert
    end

end