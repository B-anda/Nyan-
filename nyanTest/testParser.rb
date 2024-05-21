require 'test/unit'
require './scope'
require './parser'

## Testing : Parsing nyan conditions through the parser ##

class Test_ParsingAndEvaluation < Test::Unit::TestCase

  def test_simple_condition
    nyan = Nyan.new
    nyan.nyanParser.parse(
      '?nya? ^true^: 
        meow ^"hello"^
      :3' 
    ) 
  end

  def test_parse_or
    nyan = Nyan.new
      nyan.nyanParser.parse(
        '?nya? ^true || false ^: 
          meow ^"hello"^
        :3' 
      ) 
    end

  def test_complex_nested_conditions
    nyan = Nyan.new
    nyan.nyanParser.parse('
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
      
    nyan.nyanParser.parse(
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
    nyan.nyanParser.parse(
      '?nya? ^true^:
          meow ^"world"^ 

        ?nyanye? ^false^:
          meow ^"hello"^

        ?nyanye? ^false^:
          meow ^"hello world"^
        :3')
   end
                
    nyan.nyanParser.parse(
    '?nya? ^false^:
        meow ^"world"^ 

      ?nyanye? ^false^:
        meow ^"hello"^

      ?nyanye? ^true^:
        meow ^"hello world"^
      :3')
          
    nyan.nyanParser.parse(
      '?nya? ^true^:
        ?nya? ^true^:
          meow ^"hello"^
        ?nye?:
          meow ^"world"^
        :3
      :3'
    )

    nyan.nyanParser.parse(
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

    nyan.nyanParser.parse(
      ' ^3^ num_1 = 10~

        ?nya? ^(num_1 > 5)^: 
          meow ^"world"^
        :3
      ')
  end

end 

# Testing : Parsing nyan while-loop through the parser ##

class TestParsingLoop < Test::Unit::TestCase

  def test_simple_loop
    nyan = Nyan.new
    nyan.nyanParser.parse(
    '
    ^oo^ jallet = true~
    prrr ^jallet^:
      jallet = false~
      meow ^"hello"^
    :3
    '  
    ) 

    nyan.nyanParser.parse(
      ' ^3^ x = 0~
        prrr ^x < 5^:
          ?nya? ^true^:
            meow ^"meowed"^
            meow ^x^
          :3
          x += 1~
        :3
      '
    )
  end
end

## Testing: Functions ##

class Test_Function < Test::Unit::TestCase
  def test_basic_function
      nyan = Nyan.new
      program = nyan.nyanParser.parse(
      'mao test^^:
          meow^"hello"^

          ^3^ y = 42~
          meow^y^
          hsss y
          meow^"dont print this"^
          
        :3
      meow ^test^^ ^
      ' 
      ) 
  end

  def test_basic_function2
      nyan = Nyan.new
      program = nyan.nyanParser.parse(
      'mao test^^:
          meow ^1^
          meow ^2^
          meow ^3 ^
       :3
      meow ^test^^ ^
      ' 
      ) 
  end


  def test_basic_function_return
    nyan = Nyan.new
    program = nyan.nyanParser.parse(
      'mao test^^:
          meow^"hello"^

          ^3^ y = 42~
          hsss 42 + 1
      :3
      meow ^test^^ ^
      ' 
      ) 
  end
  
  def test_recursion
      nyan = Nyan.new
      program = nyan.nyanParser.parse(
          'mao recurs ^x^:
              ?nya? ^x < 3^:
                  meow^x^
                  recurs^x + 1^
              :3
          :3
          ^3^ z = 0~
          recurs^z^
          '
      )
  end
end


## Testing: Arrays ##

class Test_Arrays < Test::Unit::TestCase
  def test_simple_array
    nyan = Nyan.new
    nyan.nyanParser.parse(
      '
        ^3^ arr=[1, 2, 3]~
        meow ^arr^
      '
    )
  end

  def test_array_index
    nyan = Nyan.new
    nyan.nyanParser.parse(
      '
        ^3^ arr = [1, 2, 3]~
        ^3^ index = arr[0]~
        meow ^index^
      '
    )
  end

  def test_array_pop
      nyan = Nyan.new
      nyan.nyanParser.parse(
      '
          ^3^ arr = [1, 2, 3]~
          arr.pop
          meow ^arr^
      '
      )
  end
    
  def test_array_push
      nyan = Nyan.new
      nyan.nyanParser.parse(
      '
          ^3^ arr =[1, 2, 3]~
          arr.push^4^
          meow ^arr^
      '
      )
  end
end

## Testing: Arithmatic ##

class Test_Arithmatic < Test::Unit::TestCase
  def test_complex_arithmatics
    val1 = ValueNode.new(10)
    val2 = ValueNode.new(5)
    val3 = ValueNode.new(2.5)
    val4 = ValueNode.new(0)

    nyan = Nyan.new
    nyan.log false

    program = nyan.nyanParser.parse(
      "2+6-4"  
    ) 
    assert_equal(4, program.value)

    program2 = nyan.nyanParser.parse(
      "2+6*4"  
    ) 
    assert_equal(26, program2.value)

    program3 = nyan.nyanParser.parse(
      "(5*2)*8+(4-2)"  
    ) 
    assert_equal(82, program3.value)

    program4 = nyan.nyanParser.parse(
      "5 / 2"  
    ) 
    assert_equal(2.5, program4.value)

    program5 = nyan.nyanParser.parse(
      "5 // 2"  
    ) 
    assert_equal(2, program5.value)

    program5 = nyan.nyanParser.parse(
      "5 % 2"  
    ) 
    assert_equal(1, program5.value) 
  end

end