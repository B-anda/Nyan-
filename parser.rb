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
            token(/\^3\^/) {:integer}
            token(/\^\.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/\bprrr\b/) {:whileloop}
            token(/\^/) {|m| m}
            token(/\)/) {|m| m}
            token(/\(/) {|m| m}
            token(/\bmao\b/) {:def}
            token(/meow/) {:meow }  
            token(/\?nya\?/) {:if}
            token(/\?nye\?/) {:else}
            token(/\?nyanye\?/) {:elseif}
            token(/[[a-zA-Z]\d_]+/) {|m| m}
            token(/\:3/) {|_| ';'}
            token(/\&\&|\|\||\=\=|\/\/|\%|\<|\>|\=|\+\=|\-\=|\~|\:/) {|m| m}
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
                match(:functionCall){ |a| a }
                match(:function)    { |a| a }
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

            rule :function do
                match(:def, :variable, "^", :params, "^", ":", :blocks, ";" ) {|_, a, _, b, _, _, c, _| FunctionNode.new(a, c, b)}
                match(:def, :variable, "^", "^", ":", :blocks, ";" )          {|_, a, _, _, _, c, _| FunctionNode.new(a, c, nil)}
            end

            rule :functionCall do
                match(:variable, "^", :params, "^") {|a, _, b,_| FunctionCall.new(a, b)} 
                match(:variable, "^", "^") {|a, _, _| FunctionCall.new(a, nil)}
            end

            rule :params do
                match(:variable)               {|a| a}
                match(:params, ",", :variable) {|a, _, b| ParamsNode.new(a, b)}
            end

            ## If-statements ##
            rule :condition do
                match(:if, "^", :logicStmt, "^", ":", :blocks, :condition_followup, ";") do |_, _, a, _, _, b, c, _|
                    SharedVariables.ifBoolPush
                    BlocksNode.new(ConditionNode.new(a, b), c)
                    
                end
                match(:if, "^", :logicStmt, "^", ":", :blocks, ";") do |_, _, a, _, _, b, _|
                    SharedVariables.ifBoolPush
                    ConditionNode.new(a, b, "lone")
                end
            end
            
            rule :condition_followup do
                match( :else, ":", :blocks)                                     { |_,_, a| ConditionNode.new(ValueNode.new(true), a)}
                match( :elseif, "^", :logicStmt, "^", ":", :blocks, :condition_followup) { |_, _, a, _, _, b, c| BlocksNode.new(ConditionNode.new(a, b), c) }
                match( :elseif, "^", :logicStmt, "^", ":", :blocks) { |_, _, a, _, _, b| ConditionNode.new(a, b) }
            end

            ## While-loop ##
            rule :while do
                match(:whileloop, "^", :logicStmt, "^" , ":", :blocks, ";") { |_, _, a, _,_, b,_| WhileNode.new(a, b)}
            end

            ## Logic ##
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
                match(:integer)  {|a| DatatypeNode.new(a)}
                match(/\^\.\^/) {|a| DatatypeNode.new(a)}
                match(/\^oo\^/) {|a| DatatypeNode.new(a)}
            end

            rule :variable do
                #Key words that are not variables
                match(:integer) {}
                match(:meow)    {}
                match(:whiloop) {}
                match(:elseif)  {}
                match(:else)    {}
                #Otherwise
                match(/[[:alpha:]\d\_]+/) {|a| VariableNode.new(a)}
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
                match(/\b\d+\b/) {|a| ValueNode.new(a.to_i)}
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

    def log(state = false)
        if state
            @nyanParser.logger.level = Logger::DEBUG
        else
            @nyanParser.logger.level = Logger::WARN
        end
    end
end