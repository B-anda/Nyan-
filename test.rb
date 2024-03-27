require 'test/unit'
require './syntaxtree'

class Assignement_test < Test::Unit::TestCase
    def test_recursive_finder
        a = Assignement.new()
        test_maze = [{}, [{} ], [{}, [{}, "found me"] ], [{} ] ]
        direction = [1, 2]
        found = a.recursive_finder(test_maze, direction.dup)
        found[0][:a] = 10
        
        assert_equal("found me", a.recursive_finder(test_maze, direction.dup)[1])
        assert_equal(10, test_maze[2][1][0][:a])
        assert_false(direction.empty?)
    end

end