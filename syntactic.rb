
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


class Syntactic

  def initialize(url)
    @lex=Lexer.new(url)
  end

  def ck(gram,index,bext)
    pal=gra
  end
end
