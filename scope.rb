
class Scope
    attr_accessor :vars, :prevScope, :scopes

    def initialize(prevScope = nil)
        @vars = {}
        @scopes = []
        @prevScope = prevScope
    end

    def findVariable(name)
        if @vars.key?(name)
            return @vars[name]
        elsif @prevScope
            return @prevScope.findVariable(name) #look in the parent scope
        else
            puts "Variable #{name} not found"
            return nil
        end
    end

    def addVariable(name, value) 
        if name.is_a? VariableNode
            @vars[name.var] = value
        else
            @vars[name] = value
        end
    end

    def addScope(previousScope)
        @prevScope.addScope(previousScope)
    end
    
end

class GlobalScope < Scope
    attr_accessor :current
    def initialize
        #super()
        @vars = {}
        @scopes = []
        @current = self 
    end

    def addScope(previousScope)
        temp = Scope.new(previousScope)
        @current.scopes << temp
        @current = temp
    end
end