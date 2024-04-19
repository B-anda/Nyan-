require './rdparse'
require './syntaxtree'
require './condition'
require './scope'

class Nyan

    attr_accessor :nyanParser
    
    def initialize
        @nyanParser = Parser.new("nyan") do

            token(/\s+/)
            token(/\(/) {|m| m}
            token(/[\d]+\.[\d]+/) {|m| m}
            token(/\d+/) {|m| m }
            token(/".*"/) {|m| m}
            token(/\^w\^/) { |m| m}
            token(/\^3\^/) { |m| m}
            token(/\^\.\^/) { |m| m}
            token(/\^oo\^/) { |m| m}
            token(/\bprrr\b/) {|m|m}
            token(/\^/) {|m| m}
            token(/\)/) {|m| m}
            token(/meow/) { |_| :meow }  
            token(/\?nye\?/) {|_| :else}
            token(/\?nyanye\?/) {|_| :elseif}
            token(/\?nya\?/) { |_| :if}
            token(/[[:alpha:]\d_]+/) {|m| m}
            token(/\&\&|\|\||\=\=|\/\/|\%|\<|\>|\=|\+\=|\-\=|\~/) {|m| m}
            token(/\:3/) {|_| ';'}
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
                match(:assignment)  { |a| a }
                match(:expr)        { |a| a }
                match(:print)       { |a| a }
                match(:reassignment){ |a| a }
            end

            rule :while do
                match("prrr", "^", :logicStmt, "^" , ":", :blocks, ";") { |_, _, a, _,_, b,_| WhileNode.new(a, b)}
            end
            
            ## IF-statment ##
            rule :condition do
                match(:if, "^", :logicStmt, "^", :stmts) {|_, _, b, _,c| ConditionNode.new(b, c)}
            end

            rule :stmts do
                match(":", :condition_followup) {|_,a| a}
            end
            
            rule :condition_followup do
                match(:blocks, ";") {|a,_| a}
                match(:blocks, :elseif, "^", :logicStmt, "^", :stmts) {|prevBlock, _, _, b, _,c| BlocksNode.new(prevBlock, ConditionNode.new(b, c)) }
                match(:blocks, :else, ":", :blocks, ";") {|prevBlock, _, _, b, _| BlocksNode.new(prevBlock, ConditionNode.new(ValueNode.new(true), b)) }
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

    end

    def log(state = true)
        if state
            @nyanParser.logger.level = Logger::DEBUG
        else
            @nyanParser.logger.level = Logger::WARN
        end
    end
end