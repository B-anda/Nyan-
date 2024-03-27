require './rdparse'
require './syntaxtree'

class Nyan

    attr_accessor :nyanParser
    
    def initialize
        @nyanParser = Parser.new("nyan") do
            token(/\s+/)
            token(/\d+/) {|m| m }
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/(?<=")[[:alpha:]\s]*(?=")/) {|m| m}
            token(/"/) 
            #token(/[^"]/) {|m| m}
            token(/./) {|m| m }
            
            @a = Assignement.new()

            start :program do
                match(:component)
            end

            rule :component do
                match(:assignment)
            end

            rule :assignment do
                match(:datatype, :variable, "=", :value) { |a,b,_,c| @a.assign(a, b, c)}
            end

            rule :datatype do
                match(/\^w\^/)  {|a| a}
                match(/\^3\^/)  {|a| a}
                match(/\^\.\^/) {|a| a}
                match(/\^oo\^/) {|a| a}
            end

            rule :variable do
                match(/[[:alpha:]\d_]+/) {|a| a}
            end

            rule :value do
                match(:int) 
                match(:str) 
            end 
            
            rule :str do
                match(/[[:alpha:]\d\s]*/) {|a| a}
            end

            rule :int do
                match(/\d+/) {|a| a.to_i}
            end
            # rule :arithmatic do
            #     match(:expr, :operator, :expr) {|a, b, c| Arithmatic_Node.new(a,b,c)}
            # end

            # rule :expr do
                
            # start :expr do 
            # match(:expr, '+', :term) {|a, _, b| a + b }
            # match(:expr, '-', :term) {|a, _, b| a - b }
            # match(:term)
            # end
            
            # rule :term do 
            # match(:term, '*', :dice) {|a, _, b| a * b }
            # match(:term, '/', :dice) {|a, _, b| a / b }
            # match(:dice)
            # end

            # rule :dice do
            # match(:atom)
            # end
            
            # rule :atom do
            # # Match the result of evaluating an integer expression, which
            # # should be an Integer
            # match(Integer)
            # match('(', :expr, ')') {|_, a, _| a }
            # end
        end
    end

    def log(state = true)
        if state
            @nyanParser.logger.level = Logger::DEBUG
        else
            @nyanParser.logger.level = Logger::WARN
        end
    end
    

end