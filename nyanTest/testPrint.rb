# require 'minitest/spec'
# require 'minitest/autorun'
require 'test/unit'
require './scope'
require './syntaxtree'
require './condition'
require './parser'

# class TestPrintNode < MiniTest::Unit::TestCase

#     def test_valueNode
#         scope = GlobalScope.new
#         valueNode = ValueNode.new(42)
#         printNode = PrintNode.new(valueNode)
        
#         assert_output(/42/) {printNode.eval(scope) } 
#     end
# end