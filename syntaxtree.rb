require './scope'
require './modules.rb'

## Synatax tree nodes ##

# base class for all syntax tree nodes
class SyntaxTreeNode
    # evaluate the next node in the syntax tree within the given scope
    def evaluate(*scope)
        @nextNode.eval(scope[0])
    end
end

# represents the root the program's syntax tree
class ProgramNode < SyntaxTreeNode
    def initialize(node)
        @nextNode = node
    end
end

# represents a sequence of code blocks
class BlocksNode < SyntaxTreeNode
    include SharedVariables
    
    # include the current block and the next block
    def initialize(block, nextBlock)
        @toEval = block
        @nextBlock = nextBlock
    end

    def eval(*scope)

        toReturn = nil
        if scope[1] 
            if @toEval.is_a? BlocksNode
                return @toEval.eval(scope[0], true).insert(-1, @nextBlock)
            elsif @toEval
                return [@toEval, @nextBlock]
            else
                return [@nextBlock]
            end
        elsif @toEval
            toReturn = @toEval.eval(scope[0])
            @nextBlock.eval(scope[0])
        else
            return @nextBlock.eval(scope[0])
        end

        if @toEval.is_a? ConditionNode
            SharedVariables.ifBoolPop            
        end
        return toReturn 
    end
end

# represents an assignment of a value to a variable
class AssignmentNode < SyntaxTreeNode
    attr_accessor :datatype, :var, :value
    
    # initializes with the datatype, variable name, and value to assaign
    def initialize(datatype, var, value)
      @datatype = datatype
      @var = var
      @value = value
    end

    def eval(*scope)
        dataType = @datatype.eval
        value = @value.eval(scope[0])
        to_return = nil
        if value.is_a? ValueNode
            value = value.eval
        elsif value.is_a? Array
            return scope[0].addVariable(@var, @value)
        end

        if dataType.to_s.casecmp?(value.class.to_s)
            # assagins the value to the variable in the scope
            return scope[0].addVariable(@var, @value) 
        elsif dataType.to_s == "boolean" && (value.class.to_s == "TrueClass" || value.class.to_s == "FalseClass")
            return scope[0].addVariable(@var, @value) 
        else
            raise NyanTypeError.new
        end
    end
end

# represents a reassignment of a variable with an optional operator
class ReassignmentNode < SyntaxTreeNode
    include GetValue

    # initializes with the variable name, operator, and new value
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
                newValue = ValueNode.new(found.eval().send(@operator, @value.eval())) # operator is either '+=' or '-='
            else
                if varOrVal(@value)
                    newValue = varValToValue(@value)
                else
                    newValue = @value.eval(scope[0])
                end
            end
            scope[0].reassignVariable(@name, newValue) # reassign the variable with new value
        else
            raise NyariableNyerror.new("Nyariable #{@name} nyo nyexists, nya dumby!") # kill me
        end   

    end
end

# represents a datatype node in the syntax tree
# not implemented !
class DatatypeNode < SyntaxTreeNode
    attr_accessor :datatype
    
    def initialize(datatype)
      @datatype = datatype
    end

    def eval
        return @datatype
    end
end

# represents a variable node in the syntax tree
class VariableNode < SyntaxTreeNode
    attr_accessor :var

    # initializes with the varaible name
    def initialize(var)
        @var = var
    end

    # evaluates and returns the variable value within the given scope
    def eval(*scope)
        if scope[0].findVariable(self)
            return @var
        else 
            return nil
        end
    end
end

#represents a value node in the syntax tree
class ValueNode < SyntaxTreeNode
    attr_accessor :value
   
    # initializes with the value
    def initialize(value)
        @value = value
    end

    # converts a string to a boolean
    def convertToBool(string)
        string.casecmp("true").zero?
    end
    
    # evaluates and returns the value
    def eval(*scope)
        @value == "true" || @value == "false" ? (convertToBool(@value)) : (@value)
    end
end

# represents a print statment node in the syntax tree
class PrintNode < SyntaxTreeNode
    attr_accessor :value

    # initialize with the value to print
    def initialize(val)
        @value = val
    end

    # evaluate and prints the value within the given scope
    def eval(*scope)
        temp = nil

        if @value.is_a? VariableNode
            # find variable thats being printed 
            temp = scope[0].findVariable(@value).eval(scope[0])
            if temp.is_a? Array
                temp = temp.inspect
            elsif temp.is_a? SyntaxTreeNode 
                temp = temp.eval(scope[0])
            end
        else
            temp = @value.eval(scope[0]) 
            if temp.is_a? SyntaxTreeNode
                temp = temp.eval(scope[0])    
            end
        end

        if temp.is_a? String
            # remove " " from string
            temp = temp.delete "\"" 
        end

        puts temp
        return temp
    end
end

# represents an arithmetic operation node in the syntax tree
class ArithmaticNode < SyntaxTreeNode
    include GetValue
    
    # initializes with the left-hand side, operator, and right-hand side
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @sides = [@lhs, @rhs]
    end

    # evaluates and returns the result of the arithmetic operation
    def eval(*scope)
        begin 
        tempLhs = nodeToValue(@lhs, scope[0])
        tempRhs = nodeToValue(@rhs, scope[0])
            raise NyanZeroNyerror if tempRhs == 0 && (@operator == '/' || @operator == '//')
            if @operator == "/"
                return ValueNode.new(tempLhs.to_f.send(@operator, tempRhs.to_f))
            elsif @operator == "//"
                return ValueNode.new(tempLhs.send("/", tempRhs).to_i)
            else
                return ValueNode.new(tempLhs.send(@operator, tempRhs))
            end
        rescue StandardError => e
            puts e
        end
    end
end

# represents an array node in the syntax tree
class ArrayNode < SyntaxTreeNode
    attr_accessor :array

    # initializes with an array
    def initialize(arr)
        @array = [arr]
    end

    # evaluates and returns the array (reversed)
    def eval(*scope)
        return @array.reverse()
    end
end

# represents operations in arrays (e.g., index, push, pop, size)
class ArrayOpNode 
    attr_accessor :operation, :args

    # initializes with operation and arguments
    def initialize(operation, *args)
        @operation = operation
        @args = args
    end

    # evaluates and returns the result of the array operation within the given scope
    def eval(*scope)
        case @operation
        when :index
            var, index = @args
            puts scope[0]
            array = scope[0].findVariable(var).eval
            idx = index.eval(scope[0])

            # return given index of array
            return ValueNode.new(array[idx]) 
        when :push
            variable, value = @args
            arr = scope[0].findVariable(variable).eval
            arr.push(value.eval(scope[0]))

            # reassign array with new values
            scope[0].addVariable(variable, ValueNode.new(arr))
            return arr  
        when :pop
            variable = @args[0]
            arr = scope[0].findVariable(variable).eval
            arr.pop

            # reassign array with new values
            scope[0].addVariable(variable, ValueNode.new(arr))
            return arr  
        when :size
            variable = @args[0]
            arr = scope[0].findVariable(variable).eval
            # return size of array
            return ValueNode.new(arr.size)
        end
    end
end

# represents a parameter list node in the syntax tree
class ParamsNode < SyntaxTreeNode

    # initalizes with the current parameter and the next parameter
    def initialize(param, nextParam=nil)
        @param = param
        @nextParam = nextParam
    end

    # evaluates and adds parameters to the function node within the given scope
    def eval(funcNode, *scope)
        if @nextParam == nil
            funcNode.paramList.push(@param)
        else
            @param.eval(funcNode, scope[0])
            funcNode.paramList.push(@nextParam)
        end
    end

    # returns a list of variables in the parameter list
    def vars()
        if @param.is_a? ParamsNode
            return @param.vars().push(@nextParam)
        else
            return [@param]
        end
    end
end

# represents a function definition node in the syntax tree
class FunctionNode
    attr_accessor :paramList, :paramSize, :block

    # initializes with the function name, block, and parameters
    def initialize(name, block, params)
        @name = name       
        @block = block     
        @params = params    
        
        @paramList = []     
    end
    
    # evaluates the function definition within the given scope
    def eval(*scope)
        if @params.is_a? ParamsNode
            @params.eval(self, scope[0])
        else
            @paramList.push(@params)
        end
        scope[0].addVariable(@name, self, true) # add function name to scope
    end
end

# represents a function call node in the syntax tree
class FunctionCall
    # initializes with the function name and parameters
    def initialize(name, params)
        @name = name
        @params = params
    end

    # evaluates the function call within the given scope
    def eval(*scope)
 
        func = scope[0].findVariable(@name, true)   # find function name
        scope[0].addScope(scope[0])                 # add a new scope
        curScope = scope[0].findCurScope()          # get the current scope
        
        if @params            
            setParams = @params.vars()              # get the list of parameters
            for x in 0...setParams.length()         # iterate over the params 
                if setParams[x].is_a? VariableNode
                    value = scope[0].findVariable(setParams[x]) # find the variable's value
                elsif setParams[x].is_a? ValueNode
                    value = setParams[x]                        # use the value node directly
                else
                    value = setParams[x].eval(scope[0])         # evaluate the parameter
                end
                curScope.addVariable(func.paramList[x], value)  # add the variable to the current scope
            end
        end
        
        toEval = func.block.eval(curScope, true) # evaluate the function block with the current scope   
        
        for i in toEval
            if i.is_a? ReturnNode
                toReturn = i.eval(curScope)
                break
            else
                i.eval(curScope)
            end
        end
        curScope.currToPrevScope()           # restore the previous scope
        return toReturn                      # return the result of the function call
    end
end

class ReturnNode
    include GetValue

    def initialize(block)
        @block = block
    end

    def eval(*scope)
        if (@block.is_a? ValueNode) ||( @block.is_a? VariableNode)
            return varValToValue(@block, scope[0])
        else
            return @block.eval(scope[0])
        end
    end
end

