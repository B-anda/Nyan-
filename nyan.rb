require './parser'

class DiceRoller
        
    def DiceRoller.roll(times, sides)
      (1..times).inject(0) {|sum, _| sum + rand(sides) + 1 }
    end
    
    def initialize
      @diceParser = Parser.new("nyan") do
        token(/\s+/)
        token(/\d+/) {|m| m.to_i }
        token(/./) {|m| m }
        
        start :expr do 
          match(:expr, '+', :term) {|a, _, b| a + b }
          match(:expr, '-', :term) {|a, _, b| a - b }
          match(:term)
        end
        
        rule :term do 
          match(:term, '*', :dice) {|a, _, b| a * b }
          match(:term, '/', :dice) {|a, _, b| a / b }
          match(:dice)
        end
  
        rule :dice do
          match(:atom, 'd', :sides) {|a, _, b| DiceRoller.roll(a, b) }
          match(:atom)
        end
        
        rule :sides do
          match('%') { 100 }
          match(:atom)
        end
        
        rule :atom do
          # Match the result of evaluating an integer expression, which
          # should be an Integer
          match(Integer)
          match('(', :expr, ')') {|_, a, _| a }
        end
      end
    end
    
    def done(str)
      ["quit","exit","bye","done",""].include?(str.chomp)
    end
    
    def roll
      print "nyan "
      str = gets
      if done(str) then
        puts "Bye."
      else
        puts "=> #{@diceParser.parse str}"
        roll
      end
    end
  
    def log(state = true)
      if state
        @diceParser.logger.level = Logger::DEBUG
      else
        @diceParser.logger.level = Logger::WARN
      end
    end
  end

DiceRoller.new.roll
