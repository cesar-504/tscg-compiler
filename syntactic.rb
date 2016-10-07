
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
      return Bans.new(bext,bint)
    end
    token = token= Pila.pila2.pop
    token ||=@lex.next_token
    if  token
      pal=gram.Ps[index]
      if token.nombre == "salto" and index==0
        puts "saltando"
        
        return Bans.new(bext, )
      end
    end
  end
end
