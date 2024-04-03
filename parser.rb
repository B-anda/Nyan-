require './rdparse'
require './syntaxtree'

# regexet fungerade inte 
# /"([^"]*)"/ funkar i rubular och matchar hela strängen innanför " " och för att komma åt
#   ^     ^
# bara strängen borde det vara: a[1] 
# match(/"([^"]*)"/) {|a| ValueNode.new(a[1])} <-
#
# match(:datatype, :variable, "=", :value) { |a,b,_,c| Assignment.new(a, b, ValueNode.new(c))} 
# -> testade att lägga till ValueNode.new(c) för att skapa en ny node
#                    _       _
# varför det funka?   \('-')/ idk

# pröva lägga till rule :print men fick parse error
# `parse': Parse error. expected: '', found '^' (Parser::ParseError)



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
            token(/meow/) { |m| m }  
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/./) {|m| m }
            
            start :program do
                scope = Scope.new
                puts "Scope created in program: #{scope.inspect}"
                match(:component) {|a| a.eval(scope)}
            end

            rule :component do
                scope = Scope.new
                match(:block)
            end

            rule :block do
                scope = Scope.new
                match(:assignment) { |a| a.eval(scope) }
                match(:print) do |a| 
                    puts "Scope created in component: #{scope.inspect}"
                    a.eval(scope)
                end
                match(:condition) { |a| a.eval(scope) }
            end

            rule :assignment do
                match(:datatype, :variable, "=", :value) { |a,b,_,c| Assignment.new(a, b, ValueNode.new(c))}
            end

            rule :print do
                match("meow", "^", :output, "^") {|_,_,v,_| PrintNode.new(v)}
            end

            rule :condition do
                match("?nya?", "^" :logic_stmt, "^" :)

            rule :output do 
                match(:value)sf
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

            rule :value do
                match(:str) 
                match(:int) 
            end 
            
            rule :str do
                match(/".*"/) {|a| ValueNode.new(a)}
                #match(/"([^"]*)"/) {|a| ValueNode.new(a)}
            end

            rule :int do
                match(/\d+/) {|a| ValueNode.new(a.to_i)}
            end
        
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