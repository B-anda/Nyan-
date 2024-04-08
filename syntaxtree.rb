require './scope'

class SyntaxTreeNode
    
    def evaluate(*scope)
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
            @value = @value.value.delete "\""
            @value
        end
    end
end

