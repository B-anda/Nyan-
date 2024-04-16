require './rdparse'
require './syntaxtree'
require './condition'
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
            token(/\^/) {|m| m}
            token(/".*"/) {|m| m}
            token(/[\d]+\.[\d]+/) {|m| m}
            token(/\d+/) {|m| m }
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            # token(/^true/) { |m| m}
            # token(/false/) {|m| m}
            token(/meow/) { |_| :meow }  
            token(/\?nye\?/) {|_| :else}
            token(/\?nyanye\?/) {|_| :elseif}
            token(/\?nya\?/) { |_| :if}
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/\&\&|\|\||\=\=|\/\/|\%|\<|\>|\(|\)/) {|m| m}
            token(/\:3/) {|m| m}
            token(/./) {|m| m }
            
            @scope = GlobalScope.new

            start :program do
                match(:component) {|a| a.evaluate(@scope.current)}
            end

            rule :component do
                match(:block) {|a|ProgramNode.new(a)}
            end

            rule :stmts do
                match(":", :condition_followup) {|_,a,_| a}
            end

            rule :block do
                match(:assignment)  { |a| a }
                match(:print)       { |a| a }
                match(:condition)   { |a| a }
                match(:expr)        { |a| a }
                match(:while)       { |a| a }
            end

            ## Assign variables ##
            rule :assignment do
                match(:datatype, :variable, "=", :value) { |a,b,_,c| Assignment.new(a, b, ValueNode.new(c))}
            end

            ## Print ##
            rule :print do
                match(:meow, "^", :output, "^") {|_,_,v,_| PrintNode.new(v)}
            end

            ## IF-statment ##
            rule :condition do
                match(:if, "^", :logicStmt, "^", :stmts) {|a,_,b,_,c| ConditionNode.new(a, b, c)}
            end
            #else if takes too few args (|a,_,b,_,c|)
            rule :condition_followup do
                match(:block, ":3")
                match(:block, :elseif, "^", :logicStmt, "^", :stmts) {|prevBlock, a,_,b,_,c| ConditionNode.new(a, b, c) }
                match(:block, :else, :stmts)  {|a,_,b,_,c| ConditionNode.new(a, b, c)}
            end

            rule :logicStmt do 
                match("not", :logicStmt) { | _,b | LogicStmt.new(nil, "not", b)}
                match(:logicStmt, "and", :logicStmt) { |a,_,b| LogicStmt.new(a, "&&", b)}
                match(:logicStmt, "&&", :logicStmt)  { |a,_,b| LogicStmt.new(a, "&&", b)}
                match(:logicStmt, "or", :logicStmt)  { |a,_,b| LogicStmt.new(a, "||", b)}
                match(:logicStmt, "||", :logicStmt)  { |a,_,b| LogicStmt.new(a, "||", b)}
                match(:valueComp) 
            end

            rule :valueComp do
                match(:logicExpr, "<", :logicExpr) { |a,_,b| ValueComp.new(a, "<", b)}
                match(:logicExpr, ">", :logicExpr) { |a,_,b| ValueComp.new(a, ">", b)}
                match(:logicExpr, "<=", :logicExpr) { |a,_,b| ValueComp.new(a, "<=", b)}
                match(:logicExpr, ">=", :logicExpr) { |a,_,b| ValueComp.new(a, ">=", b)}
                match(:logicExpr, "==", :logicExpr) { |a,_,b| ValueComp.new(a, "==", b)}
                match(:logicExpr, "!=", :logicExpr) { |a,_,b| ValueComp.new(a, "!=", b)}
                match(:logicExpr)
            end

            rule :logicExpr do
                match(:value)    {|a| LogicExpr.new(a)}
                match(:variable) {|a| LogicExpr.new(a)}
                match("(", :logicStmt, ")") {|_, a, _| a}
            end

            # rule :arithmatic do
            #     match(:expr, :op, :expr) {|a, b, c| ArithmaticNode.new(a, b, c)}

            rule :expr do
                match(:expr, "+", :term) {|a,_,c| ArithmaticNode.new(a,"+",c)}
                match(:expr, "-", :term) {|a,_,c| ArithmaticNode.new(a,"-",c)}
                match(:term)
            end

            rule :term do
                match(:term, "%", :factor)  {|a,_,c|ArithmaticNode.new(a,"%",c)}
                match(:term, "//", :factor) {|a,_,c|ArithmaticNode.new(a,"//",c)}
                match(:term, "*", :factor)  {|a,_,c|ArithmaticNode.new(a,"*",c)}
                match(:term, "/", :factor)  {|a,_,c|ArithmaticNode.new(a,"/",c)}
                match(:factor)
            end

            rule :factor do
                match(:float)
                match(:int)
                match(:variable)
                match("(", :expr, ")") {|_, a, _| a}
                match(:expr)
            end

            rule :while do
                match("prrr", "^", :logic_stmt, "^", :stmts) { |_, _, a, _, b| Loop.new(a, b)}
            end
            
            ## Print either a value or a variable ##
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
                match(/[[:alpha:]\d_]+/) {|a| VariableNode.new(a)}
            end

            rule :value do
                match(:str) 
                match(:float)
                match(:int) 
                match(:bool)
            end 
            
            rule :str do
                match(/".*"/) {|a| ValueNode.new(a)}
                # match(/(?<=").*(?=")/) {|a| ValueNode.new(a)}
            end

            rule :int do
                match(/\d+/) {|a| ValueNode.new(a.to_i)}
            end

            rule :float do
                match(/[\d]+\.[\d]+/) {|a| ValueNode.new(a.to_f)}
            end

            rule :bool do
                match('true') {|a| ValueNode.new(a)}
                match('false') {|a| ValueNode.new(a)}
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