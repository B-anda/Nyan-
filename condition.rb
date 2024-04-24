require "./syntaxtree"
require "./scope"

# when the first if-stmt is evaluated it returns false which when assarted returns nil.
# which means that it doesn't move on and evaluates the next block 
# probobly need to rewrite condition_followup

# if the 'if @condition.eval(curScope)' is remove, nested if-stmts work
# but wont solve the problem 


class ConditionNode
    include SharedVariables

    def initialize(condition, block, lone=nil)
        @condition = condition
        @block = block
        @lone = lone
    end

    def eval(*scope)
        scope[0].addScope(scope[0])

        toReturn = nil
        curScope = scope[0].findCurScope()

        if SharedVariables.ifBool
            if @condition.eval(curScope)
                
                toReturn = @block.eval(curScope)
                SharedVariables.ifBool = false
            end
        end

        curScope.currToPrevScope
        curScope = nil
        
        if @lone
            SharedVariables.ifBoolPop
        end
        return toReturn
    end

end

# class ElseCondition
#    def initialize(ifCondition, elseCondition, block)
#         @ifCon = ifCondition
#         @elseCon = elseCondition
#         @block = block
#    end
   
#    def eval(*scope)
#         unless @ifCon.eval(scope[0])
#             if @elseCon.eval(scope[0])
#                 return @block.eval(scope[0])
#             end
#         end
    
#    end
# end

class LogicStmt

    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @rhs = rhs
        @operator = operator
    end

    def eval(*scope)
        # if @lhs
        #     @lhs = @lhs.eval(scope[0])
        # end
        # if @rhs
        #     @rhs = @rhs.eval(scope[0])
        # end
        # @lhs = nodeToValue(@lhs, scope[0])
        # @rhs = nodeToValue(@rhs, scope[0])
        if @lhs
            @lhs = @lhs.eval(scope[0])
        end
        @rhs = @rhs.eval(scope[0])
        
        case @operator
        when "not"
            if @rhs
                return false
            else
                return true
            end
        when "&&"
            return @rhs && @lhs
        when "||"
            return @rhs || @lhs
        end
    end 
end

class ValueComp < SyntaxTreeNode

    def initialize(lhs, logicOp, rhs)
        @lhs = lhs
        @logicOp = logicOp
        @rhs = rhs
    end

    def eval(*scope)
        # if @lhs
        #     @lhs = @lhs.eval(scope[0])
        # end
        # if @rhs
        #     @rhs = @rhs.eval(scope[0])
        # end
        # @lhs = nodeToValue(@lhs, scope[0])
        # @rhs = nodeToValue(@rhs, scope[0])
        
        # @lhs = @lhs.eval(scope[0])
        # @rhs = @rhs.eval(scope[0])

        # send calls method dynamically
        # calls @logicOp on @lhs and passes @rhs
        # which returns true or false
        
        return @lhs.eval(scope[0]).send(@logicOp, @rhs.eval(scope[0]))
    end
end

class LogicExpr

    def initialize(value)
        @value = value
    end

    def eval(*scope)

        if @value.is_a? ValueNode
            return @value.eval()
        elsif @value.is_a? VariableNode
            begin
            #     foundVariable = @value.eval(scope[0])
            
            # if foundVariable
                # puts foundVariable
                return scope[0].findVariable(@value).eval()
            rescue NyameNyerror => e
                raise NyameNyerror.new("Logic Canyot nyevaluate Nyariable #{@value.var}")
            end
            # end
        end
    end

    # def eval(*scope)
     
    #     if @value.is_a? VariableNode
    #         if scope[0].findVariable(@value.eval(scope[0]))
                
    #         end
    #     elsif @value.is_a? ValueNode
    #         if @value.value
                
    #         end
    #     end
    # end
end

class WhileNode 

    def initialize(condition, block)
        @condition = condition
        @block = block
        @toReturn = nil
    end
    
    def eval(*scope)
        if @condition.eval(scope[0])
            scope[0].addScope(scope[0])
            @block.eval(scope[0])
            scope[0].currToPrevScope()
            self.eval(scope[0])
        end
    end

end