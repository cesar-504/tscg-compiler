require_relative 'grammatics'
require_relative 'lexer'
require_relative 'token'
require_relative 'sym-table'
require_relative 'postfix'
require_relative 'semantic'
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
    @sem=Semantic.new @tableStack
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
            case @currentToken.name 
              when "inicioBloque","if","loop","cloop","tloop"
                context_push 
              when "terminacion","elif","nif"
                context_pop 
            end

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
        @sem.ck prod.name , lastNode
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
          @sem.ck p.name , lastNode
          
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
end