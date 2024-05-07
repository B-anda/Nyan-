require './scope'

# module used to handle different types of nodes
module GetValue
    def nodeToValue(side, scope)
        if (side.is_a? ValueNode) || (side.is_a? ArithmaticNode) 
            return side.eval(scope)
        elsif side.is_a? VariableNode
            return scope.findVariable(side).value
        else 
            raise NyameNyerror.new("#{side} is incorrect class type, type is #{side.class}")
        end
    end 
end

# module used to determine if the next block should be executed
module SharedVariables
    @ifBool = [true]
  
    def self.ifBool
      return @ifBool.last
    end
  
    def self.ifBool=(val)
        @ifBool.pop()
        @ifBool.push(val)
    end

    def self.ifBoolPush
        @ifBool.push(true)
    end

    def self.ifBoolPop
        @ifBool.pop()
    end
end

## Synatax tree nodes ##

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

class BlocksNode < SyntaxTreeNode
    include SharedVariables
    
    def initialize(block, nextBlock)
        @toEval = block
        @nextBlock = nextBlock
    end

    def eval(*scope)
        SharedVariables.ifBool = true
        @toEval.eval(scope[0])
        @nextBlock.eval(scope[0])
        
        if @toEval.is_a? ConditionNode
            SharedVariables.ifBoolPop
        end
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
        return scope[0].addVariable(@var, @value) # add variable to scope
    end
end

class ReassignmentNode < SyntaxTreeNode

    def initialize(name, operator, value)
        @name = name
        @operator = operator
        @value = value
    end

    def eval(*scope)
        found = scope[0].findVariable(@name) # check if variable exist
        
        if found
            newValue = nil
            if @operator != "="
                newValue = found.eval().send(@operator, @value.eval()) # operator is either '+=' or '-='
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
        if scope[0].findVariable(self)
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
        @value == "true" || @value == "false" ? (convertToBool(@value)) : (@value)
    end
end

class PrintNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def eval(*scope)
        temp = nil

        if @value.is_a?(VariableNode)            
            temp = scope[0].findVariable(@value).eval # find variable thats being printed
  
            if temp.is_a? Array
                temp = temp.inspect
            end
           
        else
            temp = @value.eval(scope[0]) # evaluate ValueNode (@value is a valueNode)

            if temp.is_a? SyntaxTreeNode
                temp = temp.eval(scope[0])    
            end

        end

        if temp.is_a? String
            temp = temp.delete "\"" # remove " " from string
        end

        puts temp
        return temp
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
        tempLhs = nodeToValue(@lhs, scope[0])
        tempRhs = nodeToValue(@rhs, scope[0])

        if @operator == "/"
            return ValueNode.new(tempLhs.to_f.send(@operator, tempRhs.to_f))
        elsif @operator == "//"
            return ValueNode.new(tempLhs.send("/", tempRhs).to_i)
        else
            return ValueNode.new(tempLhs.send(@operator, tempRhs))
        end
    end
end

class ArrayNode < SyntaxTreeNode
    attr_accessor :array
    def initialize(arr)
        @array = [arr]
    end

    def eval
        return @array.reverse()
    end
end

class ArrayOpNode 
    attr_accessor :operation, :args

    def initialize(operation, *args)
        @operation = operation
        @args = args
    end

    def eval(*scope)
        case @operation
        when :index
            var, index = @args
            array = scope[0].findVariable(var).eval
            idx = index.eval(scope[0])
            return ValueNode.new(array[idx]) # return given index of array
        when :push
            variable, value = @args
            arr = scope[0].findVariable(variable).eval
            return arr.push(value.eval(scope[0])) 
        when :pop
            variable = @args[0]
            arr = scope[0].findVariable(variable).eval
            return arr.pop
        when :size
            variable = @args[0]
            arr = scope[0].findVariable(variable).eval
            return ValueNode.new(arr.size) # return size of array
        end
    end
end


class ParamsNode < SyntaxTreeNode

    def initialize(param, nextParam=nil)
        @param = param
        @nextParam = nextParam
    end

    def eval(funcNode, *scope)

        if @nextParam == nil
            funcNode.paramList.push(@param)
        else
            @param.eval(funcNode, scope[0])
            funcNode.paramList.push(@nextParam)
        end
    end

    def vars()
        if @param.is_a? ParamsNode
            return @param.vars().push(@nextParam)
        else
            return [@param]
        end
    end
end

class FunctionNode
    attr_accessor :paramList, :paramSize, :block

    def initialize(name, block, params)
        @name = name        # name of function
        @block = block      # block inside the function
        @params = params    # function parameters
        @paramList = []     
    end
    
    def eval(*scope)
        if @params.is_a? ParamsNode
            @params.eval(self, scope[0])
        else
            @paramList.push(@params)
        end
        scope[0].addVariable(@name, self, true)
    end
end

class FunctionCall
    def initialize(name, params)
        @name = name
        @params = params
    end

    def eval(*scope)

        func = scope[0].findVariable(@name, true)
        scope[0].addScope(scope[0])
        curScope = scope[0].findCurScope()
        
        if @params            
            setParams = @params.vars()
            for x in 0...setParams.length()
                if setParams[x].is_a? VariableNode
                    value = scope[0].findVariable(setParams[x])
                else
                    value = setParams[x].eval(scope[0])
                end
                curScope.addVariable(func.paramList[x], value)
            end
        end
        
        toReturn = func.block.eval(curScope)
        curScope.currToPrevScope()
        return toReturn
    end
end


