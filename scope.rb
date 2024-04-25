require './errors'

class Scope
    attr_accessor :vars, :prevScope, :scopes

    def initialize(prevScope = nil)
        @vars = {}
        @funcs = {}
        @scopes = []
        @prevScope = prevScope
    end

    def findVariable(name)
        if @vars.key?(name.var)
            return @vars[name.var]
        elsif @prevScope
            return @prevScope.findVariable(name) #look in the parent scope
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
    
    def addVariable(name, value) 
        if name.is_a? VariableNode
            @vars[name.var] = value
        else
            @vars[name] = value
        end
    end

    def addScope(setPrevious)
        @prevScope.addScope(setPrevious)
    end

    
end

class GlobalScope < Scope
    attr_accessor :current
    def initialize
        # super()
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

        # if @current.prevScope.nil?
        #     # raise NyantimeNyerror.new()
        #     return
        # else
        #     @current = @current.prevScope
        #     @current.scopes = []
        # end
        
    end

end