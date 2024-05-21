require './scope'

# module used to handle different types of nodes
module GetValue
    def nodeToValue(side, scope)
        to_return = nil
        if (side.is_a? ValueNode) || (side.is_a? ArithmaticNode) 
            to_return = side.eval(scope)
        elsif side.is_a? VariableNode
            to_return = scope.findVariable(side).value
        else 
            raise NyameNyerror.new("#{side} is incorrect class type, type is #{side.class}")
        end

        if to_return.is_a? ValueNode
            to_return = to_return.eval(scope)
        end
        return to_return
    end 

    def varValToValue(object, *scope)
        if object.is_a? VariableNode
            return scope[0].findVariable(object)
        else
            return object
        end
    end

    # check if object is a ValueNode or VariableNode, return true, else false
    # replaces is_a?
    def varOrVal(object)
        if (object.is_a? VariableNode) || (object.is_a? ValueNode)
            return true
        else
            return false
        end
    end
end

# module used to determine if the next block should be executed
# manage shared variables across conditions
module SharedVariables
    @ifBool = []
  
    def self.ifBool
        # print "ifbool: #{@ifBool}\n"
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