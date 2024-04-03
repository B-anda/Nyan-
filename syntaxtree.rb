
class Scope
    attr_accessor :vars, :top_node

    def initialize(top_node = nil)
        @vars = {}
        @top_node = top_node
    end

    def find_variable(name)
        if @vars.key?(name)
            return @vars[name]
        elsif @top_node
            return @top_node.find_variable(name) #look in the parent scope
        else
            puts "Variable #{name} not found"
        end
    end

    def add_variable(name, value) 
        @vars[name] = value
    end
end


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
    def eval(scope)(scope)
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

        scope.add_variable(@var, value)
        # if @value.respond_to?(:eval)
        #     @value = @value.eval
        # else
        #     puts "Error: Value cannot be evaluated"
        # end
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
        scope.find_variable(@var)
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
        #puts @value.eval
        # if @value.is_a?(VariableNode)
        #     return scope.find_variable(@value)
        # else
        #     return @value
        # end
        @value
    end
end
