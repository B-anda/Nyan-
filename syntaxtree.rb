require './scope'

class SyntaxTreeNode
    attr_accessor :nodes
    
    def initialize
      @nodes = []
    end
    
    def add_child(node)
      @nodes << node
    end
end

class ProgramNode < SyntaxTreeNode
    def eval(scope)
      @nodes.each { |n| n.eval(scope) }
    end
end 

class Assignment < SyntaxTreeNode
    attr_accessor :datatype, :var, :value
    
    def initialize(datatype, var, value)
      super()
      @datatype = datatype
      @var = var
      @value = value
    end

    def eval(scope)
        value = @value.eval(scope)

        scope.addVariable(@var, value)
    end
end

class DatatypeNode < SyntaxTreeNode
    attr_accessor :datatype
    
    def initialize(datatype)
      super()
      @datatype = datatype
    end
end

class VariableNode < SyntaxTreeNode
    attr_accessor :var

    def initialize(var)
        @var = var
    end

    def eval(scope)
        if scope.findVariable(@var)
            return @var
        end
    end
end

class ValueNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(value)
        @value = value
    end
    
    def eval(scope)
      @value
    end
end

class PrintNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(val)
        super()
        @value = val
    end

    def eval(scope)
        # puts @value.eval
        if @value.is_a?(VariableNode)
            scope.findVariable(@value.var)
        else
            @value
        end
        #@value
    end
end

# class ConditionNode
    
#     def initialize(statment, condition, block)
#         @stat = statment
#         @condition = condition
#         @block = block
#     end

#     def eval

#     end

# end

class ValueComp

    def initialize(lhs, logicOp, rhs)
        @lhs = lhs
        @logicOp = logicOp
        @rhs = rhs
    end

    def eval
        #send calls method dynamically
        # calls @logicOp on @lhs and passes @rhs
        # which returns true or false

        if @lhs.value.send(@logicOp, @rhs.value)
            return true
        else
            return false
        end
    end
end

class LogicExpr

    def initialize(value)
        @value = value
    end

    def eval(scope)
        trOrFa = false
        if @value.is_a? VariableNode
            if scope.findVariable(@value.eval(scope))
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