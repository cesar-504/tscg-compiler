require_relative 'grammatics'
require_relative 'lexer'
require_relative 'token'
class GramResult
  #
  # Si se acepta una gramatica se regresa ok=true, si no se encontro ok=false, si hay error @error=Strig error
  #
  attr_accessor :error,:ok,:init
  def initialize(args)
    @error = args[:error]
    @init = args[:init]
    @ok= args[:ok]

  end

end
class Pila
    @@pila=[]
    @@pila2=[]
    def self.remover(ini,fin=-1)
        fin= fin>0&&fin<pila.count ? fin:pila.count
        for i in ini..fin
            pila.delete_at(i)
        end
    end

    def self.sacar(ini)
        while ini==pila.count
            pop=pila.pop
            pila2.push pop
        end
    end

    def self.append(s)
        pila.push s
        pila.count
    end
    def self.push(s)
        self.append(s)
    end
end

class Bans < Struct.new(:bext,:bint)
end

class Syntactic

  def initialize(url)
    @lex=Lexer.new(url)
    @ultimoToken=Token.new
    @tokenEsperado=""
    @stack=[]
    #@currentToken=nil
  end

  def check_file
     r= check_gram Gram.gram('archivo')
     return true if r.ok and !r.error
     false 
  end

  def check_prod prod
    currentToken =@stack.pop
    currentToken ||= @lex.next_token
    puts 'revisando token:'+currentToken.name+ ' produccion: '+prod.name
    if currentToken
      case prod.prodType
      when :token
          if currentToken.name==prod.name
              puts 'token aceptado: '+currentToken.name
              return GramResult.new(ok:true) 
          end
          if prod.optional
            puts 'token saltado: '+prod.name
            @stack.push currentToken
            return GramResult.new(ok:true) 
          end
        #   if currentToken.name=="terminacion" 
        #       puts 'token saltado: '+prod.name
        #       return GramResult.new(ok:true)
        #   end
      when :gram
        @stack.push currentToken
          return check_gram( Gram.gram(prod.name))
      else
        raise ' tipo gram erroneo ' + prod.name
      end


    end
    @stack.push currentToken
    return GramResult.new(error:true) 
  end

  def check_gram (gram)
    init=false
    puts "Gram: "+gram.name
          for p in gram.productions
            res= check_prod p
            if gram.optionsGr? and res.ok
                puts "gGram aceptada: "+gram.name
                return GramResult.new(ok:true)  
            elsif !gram.optionsGr? and !res.ok
                puts "Gram rechazada: "+gram.name
                return GramResult.new(error:true,init:init) 
            end
            init=true
          end
          puts "Gram aceptada: "+gram.name
        return GramResult.new(ok:true,init:init) 
  end

  # def exec()
  #   b=false
  #   if(ck(Gram.grams[0],0,b))
  #     puts "archivo validado"
  #   else
  #     puts "errores"
  #   end
  # end


  # def ck(gram,index,bext)
  #   bans=Bans.new(bext,false)
  #   #bint=false
  #   if gram.Ps.count==index
  #     bans.bext=false
  #     puts "gram: "+ gram.nombre
  #     return bans
  #   end
  #   token = token= Pila.pila2.pop
  #   token ||=@lex.next_token
  #   if  token
  #     pal=gram.Ps[index]
  #     if token.nombre == "salto" and index==0
  #       puts "saltando"
  #
  #       return ck(gram,index,bans.bext)
  #     end
  #     ipila=Pila.push
  #     puts "siguiente: "+token.nombre
  #     if pal.tipo=="token"
  #       puts "recisando token "+pal.palabra
  #       if pal.palabra==token.palabra
  #         puts "es  "+token.nombre
  #         @ultimoToken=token
  #         bans.bext=true
  #         return ck(gram,index+1, bans.bint)
  #       elsif pal.opcional
  #         puts "saltando token opcional : "+pal.palabra
  #         Pila.sacar(ipila)
  #         return ck(gram,index+1,bans.bint)
  #       else
  #         puts "No es ", pal.palabra
  #         @tokenEsperado=pal.palabra
  #         Pila.sacar(ipila)
  #         return Bans.new false,bans.bext
  #
  #       end
  #     elsif pal.tipo=="gramatica"
  #       puts "revisando gramatica "+pal.palabra
  #       Pila.sacar(ipila)
  #       i=Gram.isGram pal.palabra
  #       res = ck Gram.grams[i],0,bans.bint
  #       if res.bint
  #         bans.bext=bans.bint
  #         return ck(gram,index+1,bans.bint)
  #       elsif bans.bint
  #         bans.bext=bans.bint
  #         if Gram.grams[i].Ps.count>index
  #           puts "Error se esperaba: " + Gram.grams[i].Ps[index].palabra + " despues de "+ Pila.pila[Pila.pila.count-1].nombre+ " "+ Pila.pila[Pila.pila.count-1].nlinea + " "+token.nlinea
  #         end
  #         return Bans.new false,bans.bext
  #       elsif pal.opcional
  #         puts "saltando gramatica opcional",pal.palabra
  #         Pila.sacar(ipila)
  #         return ck gram,index+1,bans.bint
  #       else
  #         puts "errror en "+ pal.palabra
  #       end
  #       return res
  #     elsif pal.tipo="grOp"
  #       puts "revisando grOp "+pal.palabra
  #       Pila.sacar(ipila)
  #       res=ckGr(pal.opciones,token,bans.bint)
  #       if res.bint
  #         bans.bext=bans.bint;
  #         return ck(gram,index+1,bans.bint)
  #       elsif pal.opcional
  #         Pila.sacar(ipila)
  #         return ck(gram,index+1,bans.bint)
  #       end
  #       return res
  #     end
  #     print("desconocido////////////////")
  #     #stop
  #   end
  #   puts index,gram.Ps[index].palabra
  #     return Bans.new false,bans.bext
  # end

  # def ckGr (ops , palabra, bext)
  #   bans=Bans.new(bext,false)
  #   res=Bans.new(bext,false)
  #   for op in ops
  #     tmp=Gram("tmp",op.palabra)
  #     tmp.genPs()
  #     ret = ck(tmp,0,bans.bext)
  #     if(ret.bint)
  #       return ret
  #     end
  #   end
  #   return res
  # end



end
