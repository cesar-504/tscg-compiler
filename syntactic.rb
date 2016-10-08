
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
  end

  def exec()
    b=false
    if(ck(Gram.grams[0],0,b))
      puts "archivo validado"
    else
      puts "errores"
    end
  end


  def ck(gram,index,bext)
    bans=Bans.new(bext,false)
    #bint=false
    if gram.Ps.count==index
      bans.bext=false
      puts "gram: "+ gram.nombre
      return bans
    end
    token = token= Pila.pila2.pop
    token ||=@lex.next_token
    if  token
      pal=gram.Ps[index]
      if token.nombre == "salto" and index==0
        puts "saltando"

        return ck(gram,index,bans.bext)
      end
      ipila=Pila.push
      puts "siguiente: "+token.nombre
      if pal.tipo=="token"
        puts "recisando token "+pal.palabra
        if pal.palabra==token.palabra
          puts "es  "+token.nombre
          @ultimoToken=token
          bans.bext=true
          return ck(gram,index+1, bans.bint)
        elsif pal.opcional
          puts "saltando token opcional : "+pal.palabra
          Pila.sacar(ipila)
          return ck(gram,index+1,bans.bint)
        else
          puts "No es ", pal.palabra
          @tokenEsperado=pal.palabra
          Pila.sacar(ipila)
          return Bans.new false,bans.bext

        end
      elsif pal.tipo=="gramatica"
        puts "revisando gramatica "+pal.palabra
        Pila.sacar(ipila)
        i=Gram.isGram pal.palabra
        res = ck Gram.grams[i],0,bans.bint
        if res.bint
          bans.bext=bans.bint
          return ck(gram,index+1,bans.bint)
        elsif bans.bint
          bans.bext=bans.bint
          if Gram.grams[i].Ps.count>index
            puts "Error se esperaba: " + Gram.grams[i].Ps[index].palabra + " despues de "+ Pila.pila[Pila.pila.count-1].nombre+ " "+ Pila.pila[Pila.pila.count-1].nlinea + " "+token.nlinea
          end
          return Bans.new false,bans.bext
        elsif pal.opcional
          puts "saltando gramatica opcional",pal.palabra
          Pila.sacar(ipila)
          return ck gram,index+1,bans.bint
        else
          puts "errror en "+ pal.palabra
        end
        return res
      elsif pal.tipo="grOp"
        puts "revisando grOp "+pal.palabra
        Pila.sacar(ipila)
        res=ckGr(pal.opciones,token,bans.bint)
        if res.bint
          bans.bext=bans.bint;
          return ck(gram,index+1,bans.bint)
        elsif pal.opcional
          Pila.sacar(ipila)
          return ck(gram,index+1,bans.bint)
        end
        return res
      end
      print("desconocido////////////////")
      #stop
    end
    puts index,gram.Ps[index].palabra
      return Bans.new false,bans.bext
  end

  def ckGr (ops , palabra, bext)
    bans=Bans.new(bext,false)
    res=Bans.new(bext,false)
    for op in ops
      tmp=Gram("tmp",op.palabra)
      tmp.genPs()
      ret = ck(tmp,0,bans.bext)
      if(ret.bint)
        return ret
      end
    end
    return res
  end

  def verificar
    puts "verificando gramaticas"
  end

end
