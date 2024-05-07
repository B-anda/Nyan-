require "./syntaxtree"
require "./scope"

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

class LogicStmt

    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @rhs = rhs
        @operator = operator
    end

    def eval(*scope)
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
                return scope[0].findVariable(@value).eval()
            rescue NyameNyerror => e
                raise NyameNyerror.new("Logic Canyot nyevaluate Nyariable #{@value.var}")
            end
        end
    end
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