require './rdparse'
require './syntaxtree'
require './scope'

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
            token(/[\d]+\.[\d]+/) {|m| m}
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/meow/) { |m| m }  
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/\?nye\?/) {|_| :else}
            token(/\?nyanye\?/) {|_| :elsif}
            token(/\?nya\?/) { |_| :if}
            token(/\&\&|\|\||\=\=/)
            token(/./) {|m| m }
            
            # @currentscope = @scope.current
            #@scope = GlobalScope.new
            SyntaxTreeNode.scope = GlobalScope.new

            start :program do
                puts "scope created in program: #{@scope.inspect}"
                match(:component) {|a| a.eval}
            end

            rule :component do
                match(:block)
            end

            rule :stmts do
                match(":", :block, ":3") { |_, block, _| BlockNode.new(block)}
            end

            rule :block do
                match(:assignment)
                match(:print) do |_| 
                    puts "scope created in component: #{@scope.inspect}"
                end
                match(:condition) 
            end

            ## Assign variables ##
            rule :assignment do
                match(:datatype, :variable, "=", :value) { |a,b,_,c| Assignment.new(a, b, ValueNode.new(c)).eval}
            end

            ## Print ##
            rule :print do
                match("meow", "^", :output, "^") {|_,_,v,_| PrintNode.new(v, @scope)}
            end

            ## IF-statment ##
            rule :condition do
                match(:if, "^", :logicStmt, "^", :stmts)    {|a,_,b,_,c| ConditionNode.new(a, b, c, @scope).eval}
            end

            rule :condition_followup do
                match(:stmts)
                match(:elsif, "^", :logicStmt, "^", :stmts) {|a,_,b,_,c| ConditionNode.new(a, b, c, @scope).eval}
                match(:else, :condition_followup)  {|a,_,b,_,c| ConditionNode.new(a, b, c, @scope).eval}
            end

            rule :logicStmt do 
                match("not", :logicStmt) { | _,b | LogicStmt.new(nil, "not", b, @scope)}
                match(:logicStmt, "and", :logicStmt) { |a,_,b| LogicStmt.new(a, "&&", b, @scope)}
                match(:logicStmt, "&&", :logicStmt) { |a,_,b| LogicStmt.new(a, "&&", b, @scope)}
                match(:logicStmt, "or", :logicStmt) { |a,_,b| LogicStmt.new(a, "||", b, @scope)}
                match(:logicStmt, "||", :logicStmt) { |a,_,b| LogicStmt.new(a, "||", b, @scope)}
                match(:valueComp) 
                match(:logicExpr) 
            end

            rule :valueComp do
                match(:logicExpr, "<", :logicExpr) { |a,_,b| ValueComp.new(a, "<", b, @scope)}
                match(:logicExpr, ">", :logicExpr) { |a,_,b| ValueComp.new(a, ">", b, @scope)}
                match(:logicExpr, "<=", :logicExpr) { |a,_,b| ValueComp.new(a, "<=", b, @scope)}
                match(:logicExpr, ">=", :logicExpr) { |a,_,b| ValueComp.new(a, ">=", b, @scope)}
                match(:logicExpr, "==", :logicExpr) { |a,_,b| ValueComp.new(a, "==", b, @scope)}
                match(:logicExpr, "!=", :logicExpr) { |a,_,b| ValueComp.new(a, "!=", b, @scope)}
            end

            rule :logicExpr do
                match(:bool)    
                match(:variable) { |a| LogicExpr.new(a, @scope)}
                match(:value)    { |a| LogicExpr.new(a, @scope)}
            end
            
            ## Print either value or a variable ##
            rule :output do 
                match(:value)
                match(:variable)
            end

            ## The different datatypes ##
            # ^w^ String
            # ^3^ Int
            # ^.^ Float
            # ^oo^ Boolean
            rule :datatype do
                match(/\^w\^/)  {|a| DatatypeNode.new(a)}
                match(/\^3\^/)  {|a| DatatypeNode.new(a)}
                match(/\^\.\^/) {|a| DatatypeNode.new(a)}
                match(/\^oo\^/) {|a| DatatypeNode.new(a)}
            end

            rule :variable do
                match(/[[:alpha:]\d_]+/) {|a| VariableNode.new(a, @scope)}
            end

            rule :value do
                match(:str) 
                match(:int) 
                match(:float)
                match(:bool)
            end 
            
            rule :str do
                match(/".*"/) {|a| ValueNode.new(a)}
            end

            rule :int do
                match(/\d+/) {|a| ValueNode.new(a.to_i)}
            end

            rule :float do
                match(/[\d]+\.[\d]+/) {|a| ValueNode.new(a.to_i)}
            end

            rule :bool do
                match(/true/) {|a| ValueNode.new(a)}
                match(/false/) {|a| ValueNode.new(a)}
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