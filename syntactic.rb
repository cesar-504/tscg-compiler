require_relative 'grammatics'
require_relative 'lexer'
require_relative 'token'
require_relative 'sim-table'

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
    @tokenStack=[]
    @gramStack=[]
    @tableStack=[SimTable.new]
    @contextIndex=0
    @contextChange=true
    @syntaxTree=[]
    @lastAcceptedToken=nil
    @lastProd=nil
    @lastError=nil
  end



  def check_prod prod, index=0,nextProd=nil

      @currentToken ||= @lex.next_token
      
      if @currentToken

        #puts 'revisando token:'+@currentToken.name+ ' produccion: '+prod.name
        case prod.prodType
        when :token


          if @currentToken.name==prod.name

              context_push if @currentToken.name=="inicioBloque" or @currentToken.name=="if" or @currentToken.name=="loop" or @currentToken.name=="cloop" or @currentToken.name=="tloop"
              context_pop if @currentToken.name=="terminacion"

              if @currentToken.name=="pcoma"
                print_token @currentToken ,true
              else
                print_token @currentToken
              end

              
              #puts 'token aceptado: '+@currentToken.name
              @lastProd=nextProd.dclone
              @currentToken=nil
              return GramResult.new(ok:true)

          end
          
          @lastAcceptedToken=@currentToken.dclone
          #puts "Token rechazado: "+@currentToken.name
          return GramResult.new(error:true)

        when :gram
          return check_gram Gram.gram(prod.name)
        end
      end
      return GramResult.new(error:true)
  end



  def check_file
     r= check_gram Gram.gram('archivo')
     return true if !r.error
     puts "Error se esperaba [#{@lastProd.name}] pero se recibio [#{@lastAcceptedToken.name}]. #{@lastAcceptedToken.noLine}:#{@lastAcceptedToken.noColumn}  "
     false
  end


  def check_gram gram,index=0
    #puts "Gram: "+gram.name
    return check_gram_gr(gram,index) if gram.optionsGr?
    while prod=gram.productions[index]
      res= check_prod prod,0,gram.productions[index+1]
      if res.ok #or ( res.error and res.optional and prop.initial )


        if prod.final
          #puts 'Gram aceptada: '+gram.name
          return GramResult.new(ok:true)
        end
        #return check_prod2 Gram.gram(gram.productions[index+1].name)
        return check_gram gram,index+1
      else
        if prod.optional
          #return check_prod2 Gram.gram(gram.productions[index+1].name)
          return check_gram gram,index+1
        end
        #puts "Gram rechazada: #{gram.name} Error se esperaba [#{prod.name}] pero se recibio [#{@currentToken.name}]. #{@currentToken.noLine}:#{@currentToken.noColumn}  "

        return GramResult.new(error:true)
      end
      index+=1
    end
   #puts "Gram aceptada: "+gram.name
   return GramResult.new(ok:true)


  end

  def check_gram_gr gram,index=0
    while p=gram.productions[index]
      res= check_prod p,0,gram.productions[index+1]
      if res.ok
        #puts "gGram aceptada: "+gram.name
        return GramResult.new(ok:true)
      end
      index+=1
    end
    #puts "gGram rechazada: "+gram.name
    return GramResult.new(error:true)
  end

  def context_push
    @contextIndex+=1
    @contextChange=true
  end
  def context_pop
    @contextIndex-=1
    @contextChange=true
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
  end

end
