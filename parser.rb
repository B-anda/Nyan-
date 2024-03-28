require './rdparse'
require './syntaxtree'

class Nyan

    attr_accessor :nyanParser
    
    def initialize
        @nyanParser = Parser.new("nyan") do
            token(/\s+/)
            token(/"([^"]*)"/) {|m| m}
            token(/\d+/) {|m| m }
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/\^/) {|m| m}
            token(/meow/) { |m| m }  
            token(/[[:alpha:]\d_]+/) {|m| m}
#            token(/(?<=")[[:alpha:]\s]*(?=")/) {|m| m}
#            token(/"/) 
            token(/./) {|m| m }
            
            start :program do
                match(:component) {|a| a.eval}
            end

            rule :component do
                match(:assignment) {|a| a.eval}
                match(:print) {|a| a.eval}
            end

            rule :print do
                match("meow", "^", :output, "^") {|_,_,v,_| PrintNode.new(v)}
            end

            rule :assignment do
                match(:datatype, :variable, "=", :value) { |a,b,_,c| Assignment.new(a, b, ValueNode.new(c))}
            end

            rule :output do 
                match(:value)
                match(:variable)
            end

            rule :datatype do
                match(/\^w\^/)  {|a| DatatypeNode.new(a)}
                match(/\^3\^/)  {|a| DatatypeNode.new(a)}
                match(/\^\.\^/) {|a| DatatypeNode.new(a)}
                match(/\^oo\^/) {|a| DatatypeNode.new(a)}
            end

            rule :variable do
                match(/[[:alpha:]\d_]+/) {|a| VariableNode.new(a)}
            end

            #expectar en int men hittar en sträng istället vilket ger error
            rule :value do
                match(:str) 
                match(:int) 
            end 
            
            rule :str do
                match(/"([^"]*)"/) {|a| ValueNode.new(a[1])}
            end

            rule :int do
                match(/\d+/) {|a| ValueNode.new(a.to_i)}
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