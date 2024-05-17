require "./syntaxtree"
require "./scope"

# Class representing a conditional statment (e.g., if or else-if)
class ConditionNode
    include SharedVariables

    def initialize(condition, block, lone=nil)
        @condition = condition
        @block = block
        @lone = lone
    end

    def eval(*scope)
        # add a new scope for the condition
        scope[0].addScope(scope[0])

        toReturn = nil
        curScope = scope[0].findCurScope() # find the current scope

        # Check if we should evaluate the condition based on SharedVariables
        if SharedVariables.ifBool
            # if the condition is true , evaluate the block
            if @condition.eval(curScope)
                toReturn = @block.eval(curScope)
                # set ifBool to false to prevent other conditions in the same chain from evaluating
                SharedVariables.ifBool = false 
            end
        end

        curScope.currToPrevScope # move back to the previous scope
        curScope = nil
        
        # if its a lone if or else stmt, pop ifBool
        if @lone
            SharedVariables.ifBoolPop
        end
        return toReturn
    end

end

# represents a logical statment node 
class LogicStmt

    # initializes with left-hand side, operator, and right-hand side
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @rhs = rhs
        @operator = operator
    end

    # evaluates the logical statment
    def eval(*scope)
        if @lhs
            @lhs = @lhs.eval(scope[0]) # evaluate the left-hand side if it exists
        end

        if !@rhs.is_a? ValueComp
            @rhs = ValueNode.new(@rhs)
        else
            @rhs = @rhs.eval(scope[0]) # evaluate the right-hand side
        end

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

# represents a value comparison node
class ValueComp < SyntaxTreeNode

    # initializes with left-hand side, logical operator, and right-hand side
    def initialize(lhs, logicOp, rhs)
        @lhs = lhs
        @logicOp = logicOp
        @rhs = rhs
    end

    # evaluates the value comparison
    def eval(*scope)
        # perform the comparison using the logical operator
        return @lhs.eval(scope[0]).send(@logicOp, @rhs.eval(scope[0]))
    end
end

# represents a logical expression node 
class LogicExpr

    # initializes with value (could be a ValueNode or VariableNode)
    def initialize(value)
        @value = value
    end

    # evaluates the logical expression
    def eval(*scope)
        if @value.is_a? ValueNode
            return @value.eval()    # evaluate the value if it is a ValueNode
        elsif @value.is_a? VariableNode
            begin
                return scope[0].findVariable(@value).eval() # evaluate the variable
            rescue NyameNyerror => e
                raise NyameNyerror.new("Logic Canyot nyevaluate Nyariable #{@value.var}")
            end
        end
    end
end

# represents a while loop node in the syntax tree
class WhileNode 

    # initializes with a condtion and a block
    def initialize(condition, block)
        @condition = condition
        @block = block
        @toReturn = nil
    end
    
    # evaluates with the while loop
    def eval(*scope)
        if @condition.eval(scope[0])        # if the condition is true
            scope[0].addScope(scope[0])     # create a new scope
            @block.eval(scope[0])           # run the block
            scope[0].currToPrevScope()      # leave the block
            self.eval(scope[0])             # repreat until the condition is false
        end
    end

end