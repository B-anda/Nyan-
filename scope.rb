require './errors'

class Scope
    attr_accessor :vars, :prevScope, :scopes

    def initialize(prevScope = nil)
        @vars = {}
        @funcs = {}
        @scopes = []
        @prevScope = prevScope
    end

    # Find variable or function name in scope
    def findVariable(name, funcs=false)

        container = @vars
        if funcs
            container = @funcs
        end

        if container.key?(name.var)
            return container[name.var]
        elsif @prevScope
            return @prevScope.findVariable(name, funcs) #look in the parent scope
        elsif name.var == "monogatari"
            raise NyameNyerror.new
        else
            raise NyameNyerror.new( "#{name.var} nyot found")
        end
    end

    def findCurScope()
        return @prevScope.findCurScope()
    end

    def currToPrevScope()
        @prevScope.currToPrevScope()
    end
    
    # Add variable or function name to scope
    def addVariable(name, value, funcs = false) 
        container = @vars
        if funcs
            container = @funcs
        end
        if name.is_a? VariableNode
            container[name.var] = value
        else
            container[name] = value
        end
    end

    def addScope(setPrevious)
        @prevScope.addScope(setPrevious)
    end
end

class GlobalScope < Scope
    attr_accessor :current
    def initialize
        @vars = {}
        @funcs = {}
        @scopes = []
        @current = self 
    end

    def findCurScope()
        return @current
    end

    def addScope(setPrevious)
        temp = Scope.new(setPrevious)
        @current.scopes << temp
        @current = temp
        @current.scopes = []
    end

    # check previous scopes
    def currToPrevScope
        unless @current == self
            
            @current = @current.prevScope
            @current.scopes = []
        else
            # already in global scope
            # raise NyantimeNyerror.new()
            return
        end
    end
end