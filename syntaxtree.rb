require './scope'

module GetValue
    def nodeToValue(side, scope)
        if (side.is_a? ValueNode) || (side.is_a? ArithmaticNode) #|| (side.is_a? LogicStmt) || (side.is_a? ValueComp)
            return side.eval(scope)
        elsif side.is_a? VariableNode
            var = side.eval(scope)
            return scope.findVariable(var).value
        else 
            raise NyameNyerror.new("#{side} is incorrect class type")
        end
    end 
end

class SyntaxTreeNode
    
    def evaluate(*scope)
        @nextNode.eval(scope[0])
    end
end

class ProgramNode < SyntaxTreeNode
    def initialize(node)
        @nextNode = node
    end
end

class AssignmentNode < SyntaxTreeNode
    attr_accessor :datatype, :var, :value
    
    def initialize(datatype, var, value)
      @datatype = datatype
      @var = var
      @value = value
    end

    def eval(*scope)
        # value = @value.eval()
        return scope[0].addVariable(@var, @value)
    end
end

class ReassignmentNode < SyntaxTreeNode

    def initialize(name, operator, value)
        @name = name
        @operator = operator
        @value = value
    end

    def eval(*scope)
        found = scope[0].findVariable(@name.var)
        
        if found
            newValue = nil
            if @operator != "="
                newValue = found.eval().send(@operator, @value.eval())
            else
                newValue = @value.eval()
            end
            scope[0].addVariable(@name, ValueNode.new(newValue))
        end
            
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
        else 
            return nil
        end
    end
end

class ValueNode < SyntaxTreeNode
    attr_accessor :value
   
    def initialize(value)
        @value = value
    end

    def convertToBool(string)
        string.casecmp("true").zero?
    end
    
    def eval(*scope)
        # puts @value.class
        @value == "true" || @value == "false" ? (convertToBool(@value)) : (@value)
    end
end

class PrintNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def eval(*scope)
        if @value.is_a?(VariableNode)            
            temp = scope[0].findVariable(@value.var).eval
            if temp.is_a? String
                return temp.delete "\""
            end
            return temp
        else
            if @value.value.is_a? String
                return @value.value.delete "\""
            else
                return @value.value
            end
        end
    end
end

class ArithmaticNode < SyntaxTreeNode
    include GetValue
    
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @sides = [@lhs, @rhs]
    end

    def eval(*scope)
        @lhs = nodeToValue(@lhs, scope[0])
        @rhs = nodeToValue(@rhs, scope[0])

        if @operator == "/"
            return @lhs.to_f.send(@operator, @rhs.to_f)
        elsif @operator == "//"
            return @lhs.send("/", @rhs).to_i
        else
            return @lhs.send(@operator, @rhs)
        end
    end
end

