require 'test/unit'
require './scope'
require './parser'

## Testing : Parsing nyan conditions through the parser ##

class Test_ParsingAndEvaluation < Test::Unit::TestCase

    # def test_simple_condition
    #   nyan = Nyan.new
    #   program = nyan.nyanParser.parse(
    #     "?nya? ^true^: 
    #       meow ^\"hello\"^
    #     :3"  
    #   ) 
  
    #   assert_equal("hello", program)
  
    # end
  
    # def test_parse_and_or
    #   nyan = Nyan.new
    #     program = nyan.nyanParser.parse(
    #       "?nya? ^ true || false ^: 
    #         meow ^\"hello\"^
    #       :3"  
    #     ) 
    
    #     assert_equal("hello", program)
    # end
  
    # def test_complex_nested_conditions
      
    #   nyan = Nyan.new
    #   program = 
    #   "?nya? ^true^: 
    #       ?nya? ^false^: 
    #           meow ^\"hello\"^ 
    #       ?nyanye? ^true^: 
    #           ?nya? ^true^: 
    #             meow ^\"world\"^
    #           :3
    #       :3
    #   :3"
  
    #   assert_equal("world", nyan.nyanParser.parse(program))
    #   # syntaxTree = program.eval(@current_scope)
    #   # puts syntaxTree
    #   # puts nyan.nyanParser.parse(program)
    #   assert_nothing_raised do 
    #     nyan.nyanParser.parse(program)
    #   end
    # end
  
    def test_complex_logical_expressions
      nyan = Nyan.new
      # program = nyan.nyanParser.parse(
      #     "^3^ x = 10
      #      ?nya? ^(x > 5 && x < 15) || x == 20^: 
      #         meow ^true^
      #     :3")
      program = nyan.nyanParser.parse(
        ' ^3^ x = 10~
  
          ?nya? ^(x > 5)^: 
            meow ^true^
          :3
        ')
      puts program
      # puts nyan.nyanParser.parse(program)
    end
  
  #   def test_printing_complex_expressions
  #     nyan = Nyan.new
  #     program = nyan.nyanParser.parse("
        #     int x = 10
        #     meow ^(x > 5 && x < 15) || x == 20^
        # ")
  #     syntax_tree = program.eval(@current_scope)
  
  #     assert_equal 2, syntax_tree.scopes.length
      
  #     assert_output("true\n") { syntax_tree.scopes[1].eval(@current_scope) }
  #   end
  end