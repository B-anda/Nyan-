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
            token(/[\d]+\.[\d]+/) {|m| m}
            token(/\d+/) {|m| m }
            token(/".*"/) {|m| m}
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^\.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/\bprrr\b/) {:whiloop}
            token(/\^/) {|m| m}
            token(/\)/) {|m| m}
            token(/\(/) {|m| m}
            token(/meow/) {:meow }  
            token(/\?nye\?/) {:else}
            token(/\?nyanye\?/) {:elseif}
            token(/\?nya\?/) {:if}
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/\:3/) {|_| ';'}
            token(/\&\&|\|\||\=\=|\/\/|\%|\<|\>|\=|\+\=|\-\=|\~/) {|m| m}
            token(/\:/) {|m|m}
            token(/./) {|m| m }

            @scope = GlobalScope.new

            start :program do
                match(:component) {|a| a.evaluate(@scope.current)}
            end

            rule :component do
                match(:blocks) {|a|ProgramNode.new(a)}
            end

            rule :blocks do
                match(:block)          {|a| a}
                match(:blocks, :block) {|a, b| BlocksNode.new(a, b)}
            end

            rule :block do
                match(:while)       { |a| a }
                match(:condition)   { |a| a }
                match(:reassignment){ |a| a }
                match(:assignment)  { |a| a }
                match(:print)       { |a| a }
                match(:expr)        { |a| a }
            end

            ## Assign variables ##
            rule :assignment do
                match(:datatype, :variable, "=", :value, "~") { |a,b,_,c,_| AssignmentNode.new(a, b, c)}
            end

             ## Reassign variables ##
             rule :reassignment do
                match(:variable, "+=", :value, "~") { |a,_,b,_| ReassignmentNode.new(a, "+", b)}
                match(:variable, "-=", :value, "~") { |a,_,b,_| ReassignmentNode.new(a, "-", b)}
                match(:variable, "=", :value, "~")  { |a,_,b,_| ReassignmentNode.new(a, "=", b)}
            end
            
            ## Print ##
            rule :print do
                match(:meow, "^", :output, "^") {|_,_,v,_| PrintNode.new(v)}
            end

            ## IF-statment ##
            rule :condition do
                match(:if, "^", :logicStmt, "^", :stmts) {|_, _, b, _,c| ConditionNode.new(b, c)}
            end

            rule :stmts do
                match(":", :condition_followup) {|_,a| a}
            end
            
            rule :condition_followup do
                puts "inne i CF"
                match(:blocks, :else, ":", :blocks, ";")              {|prevBlock, _, _, b, _|  BlocksNode.new(prevBlock, ConditionNode.new(ValueNode.new(true), b)) }
                match(:blocks, :elseif, "^", :logicStmt, "^", :stmts) {|prevBlock, _, _, b, _, c| BlocksNode.new(prevBlock, ConditionNode.new(b, c)) }
                match(:blocks, ";") {|a,_| a}
            end

            ## While-loop ##
            rule :while do
                match(:whiloop, "^", :logicStmt, "^" , ":", :blocks, ";") { |_, _, a, _,_, b,_| WhileNode.new(a, b)}
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
                match(:logicExpr, "<", :logicExpr)  { |a,_,b| ValueComp.new(a, "<", b)}
                match(:logicExpr, ">", :logicExpr)  { |a,_,b| ValueComp.new(a, ">", b)}
                match(:logicExpr, "<=", :logicExpr) { |a,_,b| ValueComp.new(a, "<=", b)}
                match(:logicExpr, ">=", :logicExpr) { |a,_,b| ValueComp.new(a, ">=", b)}
                match(:logicExpr, "==", :logicExpr) { |a,_,b| ValueComp.new(a, "==", b)}
                match(:logicExpr, "!=", :logicExpr) { |a,_,b| ValueComp.new(a, "!=", b)}
                match(:logicExpr)
            end

            rule :logicExpr do
                match(:value)    {|a| LogicExpr.new(a)}
                match(:variable) {|a| LogicExpr.new(a)}
                match("(", :logicStmt, ")") {|_,a,_| a}
            end

            ## Arithmatic ##
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
                # match(:expr)
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
                match(/[a-zA-Z]_*-*\d+/) {|a| VariableNode.new(a)}
            end

            rule :value do
                match(:float)
                match(:int) 
                match(:bool)
                match(:str) 
            end 
            
            rule :str do
                match(/".+"/) {|a| ValueNode.new(a)}
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