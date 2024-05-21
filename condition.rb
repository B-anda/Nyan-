require "./syntaxtree"
require "./modules.rb"
require "./scope"

# Class representing a conditional statment (e.g., if or else-if)
class ConditionNode
    include SharedVariables, GetValue
    
    # initialize with condition, block, and status
    def initialize(condition, block, status=0)

        @condition = condition
        @block = block
        @status = status # status: 0, 1, 2 represnts if, elseif and else
        @first_time = true

    end

    def eval(*scope)

        scope[0].addScope(scope[0]) # add a new scope for the condition

        toReturn = nil
        curScope = scope[0].findCurScope() # find the current scope
        con = nil
        varOrVal(@condition) ? con = @condition : con = @condition.eval(curScope)

        case @status
        # @status 0 => if-statment
        when 0 then

            if @first_time then SharedVariables.ifBoolPush end
            if con.value 
                toReturn = @block.eval(curScope)

                # set ifBool to false to prevent other conditions in the same chain from evaluating
                SharedVariables.ifBool = false 
            end

        # @status 1 => elseif
        when 1 then
            
            if SharedVariables.ifBool
                if con.value 
                    toReturn = @block.eval(curScope)
                    SharedVariables.ifBool = false 
                end
            end

        # @status 2 => else
        when 2 then

            if SharedVariables.ifBool
                toReturn = @block.eval(curScope)
            end
            
        end

        curScope.currToPrevScope # move back to the previous scope
        curScope = nil
        
        first_time = false
        return toReturn
    end

end

# represents a logical statment node 
class LogicStmt
    include GetValue

    # initializes with left-hand side, operator, and right-hand side
    def initialize(lhs, operator, rhs)
        @sides = {}
        @temp = {}
        @sides[:left] = lhs
        @sides[:right] = rhs
        @operator = operator
    end

    # evaluates the logical statment
    def eval(*scope)
        #iterates through lhs and rhs
        for key, val in @sides
            key = key.to_sym
            
            if @sides[key] # if lhs exists
                
                if varOrVal(@sides[key])
                    @temp[key] = varValToValue(@sides[key], scope[0]) # sets sides to ValueNode
                else
                    @temp[key] = @sides[key].eval(scope[0]) # evaluates if side isnt ValueNode or VariableNode
                end
                
            end
        end

        case @operator
        when "not"
            if @sides[:right].eval
                return ValueNode.new(false)
            else
                return ValueNode.new(true)
            end
        when "&&"
            return ValueNode.new(@temp[:left].value && @temp[:right].value)
        when "||"
            return ValueNode.new(@temp[:left].value || @temp[:right].value)
        end
    end 
end

# represents a value comparison node
class ValueComp 
    include GetValue
    # initializes with left-hand side, logical operator, and right-hand side
    def initialize(lhs, logicOp, rhs)
        @lhs = lhs
        @logicOp = logicOp
        @rhs = rhs
    end

    # evaluates the value comparison
    def eval(*scope)
        # perform the comparison using the logical operator
        
        return ValueNode.new(@lhs.eval(scope[0]).value.send(@logicOp, @rhs.eval(scope[0]).value))
    end
end

# represents a logical expression node 
class LogicExpr
    attr_accessor :value

    # initializes with value (could be a ValueNode or VariableNode)
    def initialize(value)
        @value = value
    end

    # evaluates the logical expression
    def eval(*scope)

        if @value.is_a? ValueNode
            return @value    # evaluate the value if it is a ValueNode
        elsif @value.is_a? VariableNode

            begin
                return scope[0].findVariable(@value) # evaluate the variable
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
        if @condition.eval(scope[0]).eval  # if the condition is true
            scope[0].addScope(scope[0])     # create a new scope
            @block.eval(scope[0])           # run the block
            scope[0].currToPrevScope()      # leave the block
            self.eval(scope[0])             # repreat until the condition is false
        end
    end

end