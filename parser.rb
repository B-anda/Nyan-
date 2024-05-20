require './rdparse'
require './syntaxtree'
require './condition'
require './scope'

class Nyan

    attr_accessor :nyanParser
    
    def initialize
        @nyanParser = Parser.new("nyan") do
            
            token(/\s+/)
            token(/\:3/) {|_| ';'}
            token(/[\d]+\.[\d]+/) {|m| m}
            token(/\d+/) {|m| m }
            token(/".*"/) {|m| m}
            token(/\^w\^/) { :string }
            token(/\^3\^/) { :integer }
            token(/\^\.\^/) { :float }
            token(/\^oo\^/) { :boolean}
            token(/\bprrr\b/) {:whileloop}
            token(/\^/) {|m| m}
            token(/\(/) {|m| m}
            token(/\)/) {|m| m}
            token(/mao/) {:def}
            token(/meow/) {:meow }
            token(/push/) {:push}  
            token(/pop/) {:pop}  
            token(/size/) {:size}  
            token(/\?nya\?/) {:if}
            token(/\?nye\?/) {:else}
            token(/\?nyanye\?/) {:elseif}
            token(/hsss/) {:return}
            token(/[[a-zA-Z]\d_]+/) {|m| m}
            token(/,/) {|m| m}
            token(/\./) {|m| m}
            token(/\[/) {|m| m}
            token(/\-\=|\+\=|\+|\-|\*|\&\&|\|\||\=\=|\/\/|\%|\<|\>|\=|\]|\~|\:/) {|m| m}
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
                match(:while)           { |a| a }
                match(:condition)       { |a| a }
                match(:functionCall)    { |a| a }
                match(:function)        { |a| a }
                match(:arrayOp)         { |a| a }
                match(:reassignment)    { |a| a }
                match(:assignment)      { |a| a }
                match(:print)           { |a| a }
                match(:expr)            { |a| a }
                match(:return, :output) { |_, a| ReturnNode.new(a)}
            end

            ## Assignment ##

            rule :assignment do
                match(:datatype, :variable, "=", :value, "~") { |a,b,_,c,_| AssignmentNode.new(a, b, c)}
                match(:datatype, :variable, "=", :output, "~") { |a,b,_,c,_| AssignmentNode.new(a, b, c)}
            end

             ## Reassign variables ##

             rule :reassignment do
                match(:variable, "+=", :value, "~") { |a,_,b,_| ReassignmentNode.new(a, "+", b)}
                match(:variable, "-=", :value, "~") { |a,_,b,_| ReassignmentNode.new(a, "-", b)}
                match(:variable, "=", :value, "~")  { |a,_,b,_| ReassignmentNode.new(a, "=", b)}
                match(:variable, "=", :output, "~") { |a,_,b,_| ReassignmentNode.new(a, "=", b)}
            end

            ## Print ##

            rule :print do
                match(:meow, "^", :value, "^")  {|_,_,v,_| PrintNode.new(v)}
                match(:meow, "^", :output, "^") {|_,_,v,_| PrintNode.new(v)}
            end

            ## Print or assign either a: value, variable, array, array operator or arithmetic expr. ##

            rule :output do 
                match(:arrayOp)
                match(:array)
                match(:functionCall)
                match(:value)
                match(:expr)
                match(:variable)
            end

            ## Array ##

            rule :array do
                match("[", :elements, "]") {|_, a, _| a}
            end

            rule :elements do
                match(:value, ",", :elements) do |a, _, b| 
                    b.array << a.eval
                    b
                end
                match(:value) {|a| ArrayNode.new(a.eval)}
            end
            
            # Array operators

            rule :arrayOp do
                match(:variable, "[", :value, "]")             { |a, _, index, _| ArrayOpNode.new(:index, a, index) }
                match(:variable, ".", :push, "^", :value, "^") { |a, _, _, _, b, _| ArrayOpNode.new(:push, a, b) }
                match(:variable, ".", :pop)                    { |a, _, _| ArrayOpNode.new(:pop, a) }
                match(:variable, ".", :size)                   { |a, _, _,| ArrayOpNode.new(:size, a) }
            end

            ## Function ##

            rule :function do
                match(:def, :variable, "^", :params, "^", ":", :blocks, ";" ) {|_, a, _, b, _, _, c, _| FunctionNode.new(a, c, b)}
                match(:def, :variable, "^", "^", ":", :blocks, ";" )          {|_, a, _, _, _, c, _| FunctionNode.new(a, c, nil)}
            end

            rule :functionCall do
                match(:variable, "^", :params, "^") {|a, _, b,_| FunctionCall.new(a, b)} 
                match(:variable, "^", "^")          {|a, _, _| FunctionCall.new(a, nil)}
            end

            rule :params do
                match(:value)                  {|a| ParamsNode.new(a)}
                match(:expr)                   {|a| ParamsNode.new(a)}
                match(:variable)               {|a| ParamsNode.new(a)}
                match(:params, ",", :variable) {|a, _, b| ParamsNode.new(a, b)}
            end

            ## If-statements ##

            rule :condition do
                match(:if, "^", :logicStmt, "^", ":", :blocks, :conditionFollowup, ";") do |_, _, a, _, _, b, c, _|
                    SharedVariables.ifBoolPush
                    BlocksNode.new(ConditionNode.new(a, b, 0), c)
                    
                end
                match(:if, "^", :logicStmt, "^", ":", :blocks, ";") do |_, _, a, _, _, b, _|
                    SharedVariables.ifBoolPush
                    ConditionNode.new(a, b, 0)
                end
            end
            
            rule :conditionFollowup do
                match( :else, ":", :blocks)                                              { |_,_, a| ConditionNode.new(ValueNode.new(true), a, 2)}
                match( :elseif, "^", :logicStmt, "^", ":", :blocks, :conditionFollowup)  { |_, _, a, _, _, b, c| BlocksNode.new(ConditionNode.new(a, b, 1), c) }
                match( :elseif, "^", :logicStmt, "^", ":", :blocks)                      { |_, _, a, _, _, b| ConditionNode.new(a, b, 1) }
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
                match(:value)               {|a| LogicExpr.new(a)}
                match(:variable)            {|a| LogicExpr.new(a)}
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
                match(:floatValue)
                match(:intValue)
                match(:variable)
                match("(", :expr, ")") {|_, a, _| a}
            end

            ## The different datatypes ##
            # ^w^ String
            # ^3^ Int
            # ^.^ Float
            # ^oo^ Boolean
            
            rule :datatype do
                match(:string)  {|a| DatatypeNode.new(a)}
                match(:integer) {|a| DatatypeNode.new(a)}
                match(:float)   {|a| DatatypeNode.new(a)}
                match(:boolean) {|a| DatatypeNode.new(a)}
            end

            rule :variable do
                #Key words that are not variables
                match(:integer) {}
                match(:while)   {}
                match(:whileloop) {}
                match(:def)     {}
                match(:meow)    {}
                match(:elseif)  {}
                match(:else)    {}
                match(:return)  {}
                #Otherwise
                match(/[[:alpha:]\d\_]+/) {|a| VariableNode.new(a)}
            end

            rule :value do
                match(:floatValue)
                match(:intValue) 
                match(:boolValue)
                match(:strValue) 
                match(:array)
            end 
            
            rule :strValue do
                match(/".+"/) {|a| ValueNode.new(a)}
            end

            rule :intValue do
                match(/\b\d+\b/) {|a| ValueNode.new(a.to_i)}
            end

            rule :floatValue do
                match(/[\d]+\.[\d]+/) {|a| ValueNode.new(a.to_f)}
            end

            rule :boolValue do
                match('true')  {|a| ValueNode.new(a)}
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