require './errors'

class Scope
    attr_accessor :vars, :prevScope, :scopes

    def initialize(prevScope = nil)
        @vars = {}                  # Variables for scope
        @funcs = {}                 # Functions for scope
        @scopes = []                # Child scopes
        @prevScope = prevScope      # Parent scope
    end

    # Find variable or function name in scope
    def findVariable(name, funcs=false)

        container = @vars
        if funcs 
            container = @funcs
        end

        if container.key?(name.var)                     # checks if variable is founds in current scope
            return container[name.var]
        elsif @prevScope                                # look in the parent scope if not found in current
            return @prevScope.findVariable(name, funcs) 
        elsif name.var == "monogatari"
            raise NyameNyerror.new
        else
            raise NyameNyerror.new( "#{name.var} nyot found")
        end
    end

    # Add variable or function name to scope
    def addVariable(name, value, funcs = false)         # Assigns a variable a value
        container = @vars
        if funcs
            container = @funcs
        end
        if name.is_a? VariableNode                      # assigns variable name a value
            container[name.var] = value
        else
            container[name] = value
        end
    end
    
    def findCurScope()                                  # Sends function call to global scope
        return @prevScope.findCurScope()                
    end

    def currToPrevScope()                               # Sends function call to global scope
        @prevScope.currToPrevScope()
    end

    def addScope(setPrevious)                           # Sends function call to global scope
        @prevScope.addScope(setPrevious)
    end
end

class GlobalScope < Scope
    attr_accessor :current
    def initialize
        @vars = {}          # Variables for scope
        @funcs = {}         # Functions for scope
        @scopes = []        # Child scope
        @current = self     # Current active scope
    end

    def findCurScope()                      # Returns current active scope
        return @current
    end

    def addScope(setPrevious)               # Creates a new scope and reassigns @current
        temp = Scope.new(setPrevious)
        @current.scopes << temp
        @current = temp
        @current.scopes = []
    end

    # check previous scopes
    def currToPrevScope                     # Reassigns @current to its parent scope and deletes the old current scope
        unless @current == self
            @current = @current.prevScope
            @current.scopes = []
        else
            return
        end
    end
end