require './scope'

class SyntaxTreeNode
    
    def eval(*scope)
        @next_node.eval(scope[0])
    end
end

class ProgramNode < SyntaxTreeNode
    def initialize(node)
        @next_node = node
    end
end

class Assignment < SyntaxTreeNode
    attr_accessor :datatype, :var, :value
    
    def initialize(datatype, var, value)
      @datatype = datatype
      @var = var
      @value = value
    end

    def eval(*scope)
        value = @value.eval()
        scope[0].addVariable(@var, value)
    end
end

class DatatypeNode < SyntaxTreeNode
    attr_accessor :datatype
    
    def initialize(datatype)
      @datatype = datatype
    end
end

class VariableNode < SyntaxTreeNode
    attr_accessor :var

    def initialize(var)
        @var = var
    end

    def eval(*scope)
        if scope[0].findVariable(@var)
            return @var
        end
    end
end

class ValueNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(value)
        @value = value
    end
    
    def eval(*scope)
      @value
    end
end

class PrintNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def eval(*scope)
        if @value.is_a?(VariableNode)
            scope[0].findVariable(@value.var)
        else
            @value
        end
    end
end

class ConditionNode
    
    def initialize(statment, condition, block)
        @statment = statment
        @condition = condition
        @block = block
    end

    def eval(*scope)
        case @statment
        when :if
            if @condition.eval()
                output = @block.eval(scope[0]) #needs scope
                puts output
                return output
            end
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
        #send calls method dynamically
        # calls @logicOp on @lhs and passes @rhs
        # which returns true or false

        return @lhs.value.send(@logicOp, @rhs.value)
     
    end
end

class LogicExpr

    def initialize(value)
        @value = value
    end

    def eval(*scope)
        trOrFa = false
        if @value.is_a? VariableNode
            if scope[0].findVariable(@value.eval(scope[0]))
                trOrFa = true
            end
        elsif @value.is_a? ValueNode
            if @value.value
                trOrFa = true
            end
        end
        return trOrFa
    end
end