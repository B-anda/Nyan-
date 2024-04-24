require 'test/unit'
require './scope'
require './parser'

## Testing : Parsing nyan conditions through the parser ##

class Test_ParsingAndEvaluation < Test::Unit::TestCase

  def test_simple_condition
    nyan = Nyan.new
    program = nyan.nyanParser.parse(
      '?nya? ^true^: 
        meow ^"hello"^
      :3' 
    ) 

    assert_equal("hello", program)

  end

  def test_parse_or
    nyan = Nyan.new
      program = nyan.nyanParser.parse(
        '?nya? ^true || false ^: 
          meow ^"hello"^
        :3' 
      ) 
  
      assert_equal("hello", program)
  end

  def test_complex_nested_conditions
    nyan = Nyan.new
    program = nyan.nyanParser.parse('
    ?nya? ^true^: 
        ?nya? ^false^: 
            meow ^"hello"^ 
        ?nyanye? ^true^: 
            ?nya? ^true^: 
              meow ^"world"^
            :3
        :3
    :3')

    program1 = nyan.nyanParser.parse(
  
    ' ^3^ x = 10~
      ?nya? ^false^:
        meow ^"world"^ 
      ?nye?:
        x = 2~
        meow ^"hello"^
      :3')
      
    program2 = nyan.nyanParser.parse(
    '
      ?nya? ^true^:
        meow ^"world"^ 

      ?nyanye? ^false^:
        meow ^"hello"^

      ?nyanye? ^false^:
        meow ^"hello world"^
      :3')      
  end

  def test_nested_elseif
    nyan = Nyan.new
    nyan.log false

    assert_nothing_raised NyameNyerror do
    program = nyan.nyanParser.parse(
      '?nya? ^true^:
          meow ^"world"^ 

        ?nyanye? ^false^:
          meow ^"hello"^

        ?nyanye? ^false^:
          meow ^"hello world"^
        :3')
   end
                
    program = nyan.nyanParser.parse(
    '?nya? ^false^:
        meow ^"world"^ 

      ?nyanye? ^false^:
        meow ^"hello"^

      ?nyanye? ^true^:
        meow ^"hello world"^
      :3')
          
    program = nyan.nyanParser.parse(
      '?nya? ^true^:
        ?nya? ^true^:
          meow ^"hello"^
        ?nye?:
          meow ^"world"^
        :3
      :3'
    )

    program = nyan.nyanParser.parse(
      '?nya? ^true^:
        ?nya? ^false^:
          meow ^"world"^
        :3
        ?nye?:
        meow ^"hello"^
        :3'
    )

  end
  
  def test_complex_logical_expressions
    nyan = Nyan.new
    program1 = nyan.nyanParser.parse(
        '^3^ x = 10~
          ?nya? ^(x > 5 && x < 15) || x == 20^: 
            meow ^"hello"^
        :3')

    program2 = nyan.nyanParser.parse(
      ' ^3^ num_1 = 10~

        ?nya? ^(num_1 > 5)^: 
          meow ^"world"^
        :3
      ')
  end

end 

## Testing : Parsing nyan while-loop through the parser ##

class TestParsingLoop < Test::Unit::TestCase

  def test_simple_condition
    nyan = Nyan.new
    program = nyan.nyanParser.parse(
    '
    ^oo^ jallet = true~
      prrr ^jallet^:
      jallet = false~
      meow ^"hello"^
      :3
    '  
  ) 

    program2 = nyan.nyanParser.parse(
      '^3^ x=0~
      prrr ^x < 5^:
        ?nya? ^true^:
          meow ^"meowed"^
          meow ^x^
        :3
        x+=1~
      :3'
    )

  end

end
