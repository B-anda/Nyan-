require "./syntaxtree"
require "./scope"

class ConditionNode
    
    def initialize(statment, condition, block)
        @statment = statment
        @condition = condition
        @block = block
    end

    def eval(*scope)
        scope[0].addScope(scope[0])

        if @statment == :if || @statment == :elsif
            if @condition.eval()
                @block.eval(scope[0]) 
            end
        elsif(@statment == :else)
            @block.eval(scope[0])
        end

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
        if @rhs
            @rhs = @rhs.eval(scope[0])
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

class ValueComp

    def initialize(lhs, logicOp, rhs)
        @lhs = lhs
        @logicOp = logicOp
        @rhs = rhs
    end

    def eval(*scope)
        if @lhs
            @lhs = @lhs.eval(scope[0])
        end
        if @rhs
            @rhs = @rhs.eval(scope[0])
        end
        # send calls method dynamically
        # calls @logicOp on @lhs and passes @rhs
        # which returns true or false
        puts @lhs.send(@logicOp, @rhs)
        return @lhs.send(@logicOp, @rhs)
    end
end

class LogicExpr

    def initialize(value)
        @value = value
    end

    def eval(*scope)

        if @value.is_a? ValueNode
            return @value.value
        elsif @value.is_a? VariableNode
            find_variable = scope[0].findVariable(@value.eval(scope[0]))

            if find_variable
                return find_variable.value
            end
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