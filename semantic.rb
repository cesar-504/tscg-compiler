require_relative 'sym-table'
require_relative 'postfix'
require_relative 'token'
require 'tree'
class Semantic
    def initialize tableStack
        @tableStack = tableStack
    end

    def ck name,node
        begin
            send "ck_"+p.name , lastNode# ck_declaracion lastNode
        rescue NoMethodError 
        end
    end

    def evaluate_pfix tokens
    stack = []

    tokens.each do |token|
      
      case token.name when "num","real","string","boolVal"
        stack.push(token)
        when "identificador"
          
          if (sym=search_id_in_tableStack token.val)
            t = Token.new(sym.ctype,nil,sym.ctype,token.noLine,token.noColumn)
            stack.push(t) 
          else
            abort "variable [#{token.val}] no definida. #{token.noLine}:#{token.noColumn} "
          end
      else 
         rhs = stack.pop
         lhs = stack.pop
        case token.val 
          when "+","*","-",">","<",">=","<=","==","!=","&&","||"
            stack.push Token.new  ck_ope( lhs,rhs),nil,nil,rhs.noLine,rhs.noColumn
          when "/"
            stack.push Token.new "real",nil,nil,rhs.noLine,rhs.noColumn
        else
         
          abort "token desconocido #{token.val}. #{token.noLine}:#{token.noColumn} "
        end
      end
      
        
      
    end

    stack.pop.name
    end

  def ck_ope (lhs,rhs)
    return "num" if (lhs.name=="num" and rhs.name=="num") 
    return  "real" if (lhs.name=="num" and rhs.name=="real") or (lhs.name=="real" and rhs.name=="real") or  (lhs.name=="real" and rhs.name=="num") 
    return "string" if (lhs.name=="string" and rhs.name=="string")
    return Token.new "boolVal" if (lhs.name=="boolVal" and rhs.name=="boolVal")
    abort "Error: tipos no compatible para la operacion :[#{lhs.name}] [#{rhs.name}]. #{rhs.noLine}:#{rhs.noColumn} " 
  end

  def node_to_array node
    array=[]
    node.each { |n| array<< n.content if n.children.count==0 }
    array
  end

  def search_id_in_tableStack id
    @tableStack.reverse_each do |item|
        s=item.search_id id 
       return s if s
    end
    nil
  end

  def ck_opAsignacion node
    array = node_to_array node
    array.shift
    result=nil
    
      array = PostFix.infix_to_posfix  array
      result = evaluate_pfix array
    
    abort "error en tokens" if !result
    result
  end

  def ck_condiciones node
    array = node_to_array node
    result=nil
    
    puts "hola ////////"
    array = PostFix.infix_to_posfix array
    
    abort "error en tokens" if !result
    return result
   
  end

  def ck_declaracion node
    sim=SymbolStr.new(node.children[1].content.val,nil,:var)
    if @tableStack[@contextIndex].exist_in_table? sim
        abort "Error redefinicion de variable : #{sim.name} #{node.children[1].content.noLine}:#{node.children[1].content.noColumn}"
    end
    puts    
    opasig= ck_opAsignacion node.children[4]
    abort "tipo de variable [#{ node[3].content.val}] no coincide con el de la expresion asignada asignada [#{opasig}] #{node[3].content.noLine}:#{node[3].content.noColumn}" if opasig != node[3].content.val and !(opasig=="num" and node[3].content.val=="real")
    sim.ctype=node[3].content.val
    @tableStack[@contextIndex].add_symbol sim
  end
    
end