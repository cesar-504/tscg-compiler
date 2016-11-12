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
        if prod.name=="declaracion"
          puts
          ck_declaracion lastNode
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

        @errorsStack<< "Gram rechazada: #{gram.name} Error se esperaba [#{prod.name}] pero se recibio [#{@currentToken.name}]. #{@currentToken.noLine}:#{@currentToken.noColumn}  "

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
        if p.name=="declaracion"
          puts
          ck_declaracion lastNode
        end
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
    sim=SymbolStr.new(node.children[1].content,node.children[2].content,:var)
    if @tableStack[@contextIndex].exist_in_table? sim
        abort "Error redefinicion de variable : #{sim.name} #{node.children[1].content.noLine}:#{node.children[1].content.noColumn}"
    end
    puts    
    opasig= ck_opAsignacion node.children[4]
    @tableStack[@contextIndex].add_symbol sim
  end

  def ck_opAsignacion node
    array=[]
    node.each { |n| array<< n.content if n.children.count==0 }
    array.shift
    
    array = to_postfix  array
    result = evaluate_pfix array
    puts result
    puts array
    puts
    
  end

  def is_num?(n)
	  n =~ /\d+\.?\d*/		
  end
  def is_id?(n)
    n =~ /[a-zA-Z_]\w*/		
  end


  def to_postfix tokens
    stack = []
    out=[]
    prec ={
      "^"=>4,
      "*"=>3,
      "/"=>3,
      "+"=>2,
      "-"=>2,
      "("=>1
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
      if is_num? t.val or is_id? t.val
        sumVar+=1
        out.push t
      elsif t.val == "("
        stack.push t
      elsif t.val==")"
        while stack.last.val != "("
          if !stack.last
            abort "error: falta: ("
            error=true
            break;
          end
          out.push stack.pop  
          
        end
        stack.pop if stack.last.val=="("
      elsif t.val =~ /[+\-*\/]/
        sumOp+=1
        out.push stack.pop while stack.last and prec[stack.last.val] >= prec[t.val]
        
        stack.push t
      else
        abort  "error: inesperado: "+t 
        error=true
        break;
      end
      i+=1
    end
    stack.each{|item| abort  "error: falta: )" if item.val=="("} if stack
    
      
    if sumOp!=sumVar-1 or (sumOp==0 and sumVar==0)
      abort "error: numero de operadores y operandos no corresponde"
    elsif !error
      stack.reverse.each{ |op| out.push op }
      puts out.join(" ")
      return out
    end
  end

  def evaluate_pfix tokens
    stack = []

    tokens.each do |token|
      if token.name="numero" or token.name="numeroR" or token.name="string" or token.name="boolVal"
        stack.push(token)
      elsif token == "+"
        rhs = stack.pop
        lhs = stack.pop
        stack.push ch_ope( lhs,rhs)
      elsif token == "*"
        rhs = stack.pop
        lhs = stack.pop
        stack.push ch_ope( lhs,rhs)
      elsif token == "-"
        rhs = stack.pop
        lhs = stack.pop
        stack.push ch_ope( lhs,rhs)
      elsif token == "/"
        rhs = stack.pop
        lhs = stack.pop
        stack.push "numeroR"
      else
        abort "toeken desconocido"
      end
    end

    stack.pop.name
  end
  def ck_ope (lhs,rhs)
    return "numero" if (lhs.name=="numero" and rhs.name=="numero") 
    return "numeroR" if (lhs.name=="numero" and rhs.name=="numeroR") or (lhs.name=="numeroR" and rhs.name=="numeroR") or  (lhs.name=="numeroR" and rhs.name=="numero") 
    return "string" if (lhs.name=="string" and rhs.name=="string")
    return "boolVal" if (lhs.name=="boolVal" and rhs.name=="boolVal")
    abort "tipos no compatible para la operacion:[#{lhs.name}] [#{rhs.name}]. #{lhs.noLine}:#{lhs.noColumn} " 
  end

end
