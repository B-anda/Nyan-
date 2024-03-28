require 'test/unit'
require './syntaxtree'

class Assignment_test < Test::Unit::TestCase
    # def test_recursive_finder
    #     a = Assignement.new()
    #     test_maze = [{}, [{} ], [{}, [{}, "found me"] ], [{} ] ]
    #     direction = [1, 2]
    #     found = a.recursive_finder(test_maze, direction.dup)
    #     found[0][:a] = 10
        
    #     assert_equal("found me", a.recursive_finder(test_maze, direction.dup)[1])
    #     assert_equal(10, test_maze[2][1][0][:a])
    #     assert_false(direction.empty?)
    # end

    def test_initiaize
        a = Assignment.new("^w^", "hello", "world")

        assert_equal("^w^", a.datatype)
        assert_equal("hello", a.var)
        assert_equal("world", a.value)
    end

    def test_eval
        value = ValueNode.new("world")
        assignment = Assignment.new("^w^", "test_str", value)
        assert_equal("world", assignment.eval)
    end

end

class Datatype_Test < Test::Unit::TestCase
    def test_initiaize
        datatype = DatatypeNode.new("^w^")
        assert_equal("^w^", datatype.datatype)
    end
end




