
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

Bans = Struct.new(:bext,:bint)

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
    bint=false
    if gram.Ps.count==index
      bext=false
      puts "gram: "+ gram.nombre
      return true
    end
    token = token= Pila.pila2.pop
    token ||=@lex.next_token
    if  token
      pal=gram.Ps[index]
      if token.nombre == "salto" and index==0
        puts "saltando"

        return ck(gram,index,bext)
      end
      ipila=Pila.push
      puts "siguiente: "+token.nombre
      if pal.tipo=="token"
        puts "recisando token "+pal.palabra
        if pal.palabra==token.palabra
          puts "es  "+token.nombre
          @ultimoToken=token
          bext=true
          return ck(gram,index+1, bint)
        elsif pal.opcional
          puts "saltando token opcional : "+pal.palabra
          Pila.sacar(ipila)
          return ck(gram,index+1,bint)
        else
          puts "No es ", pal.palabra
          tokenEsperado=pal.palabra
          Pila.sacar(ipila)
          return false

        end
      elsif pal.tipo=="gramatica"
        puts "revisando gramatica "+pal.palabra
        Pila.sacar(ipila)
        i=Gram.isGram pal.palabra
        res = ck Gram.grams[i],0,bint
        if res
          bext=bint
          return ck(gram,index+1,bint)
        elsif bint
          bext=bint
          if Gram.grams[i].Ps.count>index
            puts "Error se esperaba: " + Gram.grams[i].Ps[index].palabra + " despues de "+ Pila.pila[Pila.pila.count-1].nombre+ " "+ Pila.pila[Pila.pila.count-1].nlinea + " "+token.nlinea
          end
          return false
        elsif pal.opcional
          puts "saltando gramatica opcional",pal.palabra
          Pila.sacar(ipila)
          return ck gram,index+1,bint
        else
          puts "errror en "+ pal.palabra
        end
        return res
      elsif pal.tipo="grOp"
        puts "revisando grOp "+pal.palabra
        Pila.sacar(ipila)
        res=ckGr(pal.opciones,token,bint)
        if res
          bext=bint;
          return ck(gram,index+1,bint)
        elsif pal.opcional
          Pila.sacar(ipila)
          return ck(gram,index+1,bint)
        end
        return res
      end
      print("desconocido////////////////")
      #stop
    end
    puts index,gram.Ps[index].palabra
      return false
  end

  def ckGr (ops , palabra bext)
    res=false
    for op in ops
      tmp=Gram("tmp",op.palabra)
      tmp.genPs()
      ret = ck(tmp,0,bext)
      if(ret)
        return true
      end
    end
    return res
  end

  def verificar
    puts "verificando gramaticas"
  end

end
