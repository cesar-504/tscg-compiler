require_relative 'grammatics'
require_relative 'lexer'
require_relative 'token'
require_relative 'sym-table'

require 'tree'

class Object
  def dclone
    # Abracadabra !!!
    Marshal::load(Marshal::dump(self))
  end
end

class GramResult
  #
  # Si se acepta una gramatica se regresa ok=true, si no se encontro ok=false, si hay error @error=Strig error
  #
  attr_accessor :error,:ok,:init,:pass
  def initialize(args)
    @error = args[:error]
    @init = args[:init]
    @ok= args[:ok]
    @pass=args[:pass]
  end

end

class Syntactic

  def initialize(url)
    @lex=Lexer.new(url)
    @currentToken=nil
    @delCurrentToken=true
    @tokenStack=[]
    @gramStack=[]
    @tableStack=[SymTable.new]
    @errorsStack=[]
    @contextIndex=0
    @contextIndexOld=0
    @contextChange=true
    @syntaxTree=Tree::TreeNode.new("ROOT", "Root Content")
    @symbolsTree=Tree::TreeNode.new("ROOT", "Root Content")
    @currentNode=@syntaxTree
    @lastAcceptedToken=nil
    @lastProd=nil
    @lastError=nil
    @treeIndex=0
  end



  def check_prod prod, index=0,nextProd=nil
      if @delCurrentToken
        @currentToken = @lex.next_token
        @delCurrentToken=false
      end


      if @currentToken

        #puts 'revisando token:'+@currentToken.name+ ' produccion: '+prod.name
        case prod.prodType
        when :token


          if @currentToken.name==prod.name

              context_push if @currentToken.name=="inicioBloque" or @currentToken.name=="if" or @currentToken.name=="loop" or @currentToken.name=="cloop" or @currentToken.name=="tloop"
              context_pop if @currentToken.name=="terminacion" or @currentToken.name=="elif" or @currentToken.name=="nif"

              if @currentToken.name=="pcoma"
                print_token @currentToken ,true
              else
                print_token @currentToken
              end


              #puts 'token aceptado: '+@currentToken.name

              @lastProd=nextProd.dclone
             @delCurrentToken=true
              return GramResult.new(ok:true)

          end

          @lastAcceptedToken=@currentToken.dclone
          @errorsStack << "Error se esperaba #{prod.name} pero se recibio #{@currentToken.name}. [#{@currentToken.noLine}:#{@currentToken.noColumn}]"
          @errorsStack << "Token rechazado: "+@currentToken.name
          return GramResult.new(error:true)

        when :gram
          #@currentNode<<Tree::TreeNode.new("[#{@currentNode.count-1}] #{prod.name}" )
          #@currentNode=@currentNode.children.last
    #       @last2=Tree::TreeNode.new("[#{@currentNode.count-1}] #{prod.name}" )
    # @currentNode<<@last2
          return check_gram Gram.gram(prod.name)
        end
      end
      return GramResult.new(error:true)
  end



  def check_file
      #lastNode=Tree::TreeNode.new("[#{@currentNode.count-1}] #{prod.name}")
      @name="[#{@currentNode.count-1}] archivo"
      lastNode=Tree::TreeNode.new(@name)

      @currentNode<<lastNode
      @currentNode=lastNode
     r= check_gram Gram.gram('archivo')
     @syntaxTree.print_tree
     return true if !r.error
     puts "Error se esperaba [#{@lastProd.name}] pero se recibio [#{@lastAcceptedToken.name}]. #{@lastAcceptedToken.noLine}:#{@lastAcceptedToken.noColumn}  "
     puts "errorStack"
     puts @errorsStack
     false
  end

  def check_gram gram,index=0
    #puts "Gram: "+gram.name


    return check_gram_gr(gram,index) if gram.optionsGr?
    while prod=gram.productions[index]
      indexError=@errorsStack.count
      lastNode=Tree::TreeNode.new("[#{@currentNode.count-1}] #{prod.name} #{prod.prodType}")
      @currentNode<<lastNode
      @currentNode=lastNode if prod.prodType==:gram
      res= check_prod prod,0,gram.productions[index+1]
      lastNode.content=@currentToken.dclone
      @currentNode=@currentNode.parent if prod.prodType==:gram
      if res.ok #or ( res.error and res.optional and prop.initial )
        pop_errors_at indexError
        if prod.final
          #puts 'Gram aceptada: '+gram.name

          #@currentNode=@currentNode.parent
          return GramResult.new(ok:true)
        end
        begin
            send "ck_"+prod.name , lastNode# ck_declaracion lastNode
        rescue NoMethodError
        end
        #return check_prod2 Gram.gram(gram.productions[index+1].name)
        return check_gram gram,index+1

      else
        #@currentNode=lastNode
        @currentNode=lastNode.parent
        @currentNode.remove!(lastNode)
        @currentNode.remove!(@last2)
        if prod.optional
          #return check_prod2 Gram.gram(gram.productions[index+1].name)

          return check_gram gram,index+1
        end
        abort "Gram rechazada: #{gram.name} Error se esperaba [#{prod.name}] pero se recibio [#{@currentToken.name}]. #{@currentToken.noLine}:#{@currentToken.noColumn}  " if !prod.initial
        #@errorsStack<< "Gram rechazada: #{gram.name} Error se esperaba [#{prod.name}] pero se recibio [#{@currentToken.name}]. #{@currentToken.noLine}:#{@currentToken.noColumn}  "

        return GramResult.new(error:true)
      end
      index+=1
    end
   puts "Gram aceptada: "+gram.name 
   return GramResult.new(ok:true)


  end

  def check_gram_gr gram,index=0
    while p=gram.productions[index]
      lastNode=Tree::TreeNode.new("[#{@currentNode.count-1}] #{p.name} #{p.prodType}")
      @currentNode<<lastNode
      @currentNode=lastNode if p.prodType==:gram
      res= check_prod p,0,gram.productions[index+1]
      lastNode.content=@currentToken.dclone
      if p.prodType==:gram
        @currentNode=@currentNode.parent
        # tmp=""
        # while @currentNode.children.count==1 and @currentNode.name!=tmp
        #   tmp=@currentNode.name
        #   @currentNode=@currentNode.children.last

        #   @currentNode=@currentNode.parent

        #  end
      end

      if res.ok
        #puts "gGram aceptada: "+gram.name
        #if p.name=="declaracion"
          puts
          begin
            send "ck_"+p.name , lastNode# ck_declaracion lastNode
          rescue NoMethodError
          end
        #end
        
        return GramResult.new(ok:true)
      else
        @currentNode=lastNode.parent
        @currentNode.remove!(lastNode)
        @currentNode.remove!(@last2)
      end
      index+=1
    end

    #puts "gGram rechazada: "+gram.name
    return GramResult.new(error:true)
  end

  def context_push
    
    @contextIndex=@tableStack.count
    @contextChange=true
    @tableStack.push SymTable.new

    #@currentNode=@currentNode.children.last
  end
  def context_pop
    @contextIndex-=1
    @contextChange=true
    @tableStack.pop
    #@currentNode=@currentNode.parent
  end

  def end_instruction

  end

  def add token
    @syntaxTree[@contextIndex].push token

  end

  def print_token(token,nline=false)

      print token.name+ " "
      if @contextChange or nline
        print"\n"+" -> " * @contextIndex + "[#{@contextIndex}] "
      end
      @contextChange=false
      puts() if token.name=="finalArchivo"
  end

  def pop_errors_at index
    @errorsStack.pop while @errorsStack.count!=index
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

  def node_to_array node
    array=[]
    node.each { |n| array<< n.content if n.children.count==0 }
    array
  end

  def ck_opAsignacion node
    array = node_to_array node
    array.shift
    result=nil
    
      array = to_postfix  array
      result = evaluate_pfix array
    
    abort "error en tokens" if !result
    result
\
  end


  def to_postfix tokens
    stack = []
    out=[]
    prec ={
      "^"=>10,
      "*"=>9,
      "/"=>9,
      "+"=> 7,
      "-"=>7,
      "("=>5,
      "<"=>4,
      ">"=>4,
      "<="=>4,
      ">="=>4,
      "=="=>3,
      "!="=>3,
      "&&"=>2,
      "||"=>1
    }
    assoc ={
      "^":'r',
      "*":'l',
      "/":'l',
      "+":'l',
      "-":'l',
      "(":'l'
    }
    sumOp=0
    sumVar=0
    error=false
    #puts tokens
    puts
     i=0
    for t in tokens
    #puts t
      if (t.name=="num" or t.name=="real") or t.name=="identificador" or t.name=="string" 
        sumVar+=1
        out.push t
      elsif t.val == "("
        stack.push t
      elsif t.val==")"
        while stack.last.val != "("
          if !stack.last
            abort "error: falta: (. #{t.noLine}:#{t.noColumn}" 
            error=true
            break;
          end
          out.push stack.pop  
          
        end
        stack.pop if stack.last.val=="("
      elsif t.name=="oprMat" or t.name=="oprComp"  or t.name=="oprLog"
        sumOp+=1
        out.push stack.pop while stack.last and prec[stack.last.val] >= prec[t.val]
        
        stack.push t
      else
        abort  "error: inesperado: #{t.name }. #{t.noLine}:#{t.noColumn}"
        error=true
        break;
      end
      i+=1
    end
    stack.each{|item| abort  "error: falta: ). #{t.noLine}:#{t.noColumn}" if item.val=="("} if stack
    
      
    if sumOp!=sumVar-1 or (sumOp==0 and sumVar==0)
       abort "error: numero de operadores y operandos no corresponde. "
    elsif !error
      
      return out
    end
  end

  def search_id_in_tableStack id
    @tableStack.reverse_each do |item|
        s=item.search_id id 
       return s if s
    end
    nil
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

  def ck_condiciones node
    array = node_to_array node
    result=nil
    
    puts "hola ////////"
    array = to_postfix array
    
    abort "error en tokens" if !result
    return result
   
  end

end
