# #scope
# @@scopes = [{}]
# @@cur_scope = []

def recursive_iterator(scope_list, directions) # scope_list = @@scopes | directions = @@cur_scope.dup (has to be a duplicated list) 
    # print scope_list, "\n"
    
    if directions.empty? != TRUE
        temp = directions.pop
        current = scope_list[temp]
        return recursive_finder(current, directions)
    else
        puts "returning"
        return scope_list
    end
end

# class Assignement
#     attr_accessor 
#     def initialize(datatype, var, value)   
#         @datatype = datatype
#         @var = var
#         @value = value
#     end

    

#     # def assign(datatype, key, val)
#     #     @datatype = datatype
#     #     @var = key
#     #     @value = val
        
#     #     puts check_value
        
#     #     if check_value
#     #         to_assign = recursive_iterator(@@scopes, @@cur_scope.dup)[0]
#     #         to_assign[key] = val

#     #         puts @@scopes
#     #     else
#     #         puts "the value #{val} does not match the datatype #{datatype}"
#     #     end
#     # end

#     def eval 

#     end

#     def check_value
#         check = false
        
#         case @datatype
#         when "^w^"
#             if @value.is_a? String
#                 check = true
#             end
#         when "^3^"
#             if @value.is_a? Integer
#                 check = true
#             end
#         when "^.^"
#             if @value.to_f
#                 check = true
#             end
#         when "^oo^"
#             if @value
#                 @value = true
#             else
#                 @value = false
#             end
#             check = true
#         end
        
#         return check
#     end
# end

# class Arithmatic_Node
#     def initialize(operand1, operator, operand2)
#         @operator = operator
#         @operand1 = operand1
#         @operand2 = operand2
#     end

# end




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
    def eval
      @nodes.each(&:eval)
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

    def eval
        value = @value.eval
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

    def eval
      @var
    end
end

class ValueNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(value)
        @value = value
    end

    def eval
      @value
    end
end

class PrintNode < SyntaxTreeNode
    attr_accessor :value

    def initialize(val)
        super()
        @value = val
    end

    def eval
        puts @value.eval
    end
end
