
class Production
  attr_accessor :name , :prodType,:optional,:initial,:final
  def initialize(name,optional=false,prodType="",initial=false,final=false)
    @name=name
    @prodType=prodType
     @optional=optional
     @initial=initial
     @final=final
    # @groupOp=group
    # @opciones =opciones

  end

end


class Gram
  attr_accessor :name , :productionText,:optionsGr,:productions
  def optionsGr?()
    @optionsGr
  end
  def initialize(name,productionText,optionsGr=false)
        @name=name
        @productionText=productionText
        @productions=[]
        @optionsGr=optionsGr

        # @optional=optional
        # @group=group
        # @opciones =opciones
        #genProductions
  end
  def self.init
    for gr in @@grams
      gr.genProductions
    end
  end
  def self.print2
    for gr in @@grams
        grOp=""
        grOp="[grOp]" if gr.optionsGr?
        #puts gr.name + grOp +  " --> " + gr.productionText.to_s
        print gr.name + grOp + '    prd-> '
        for p in gr.productions
            print p.name
            print "?" if p.optional
            print " ,"
        end
        puts
    end
  end

  def genProductions
    array = @productionText.split( /\s|(\|)|(\,)|(\()|(\))|(\?)/).reject { |c| c.empty? }

    i=0
    while elem=array[i]
      case elem
      when ")"
        i+=1
        next
      when "?"

        if(@productions.last)
          @productions.last.optional=true
          @productions.last.final=true if i==array.length-1
        else
          ##error
          raise "error en ? gram " + array.join(" ")
        end
      when "(" #solo soporta un nivel #falta optimizacion
          if(to=array[i..-1].index ")")
            tmp = array[i+1..to+i-1]
            (f = tmp.find_index(")")) && tmp.delete_at(f)
            group=tmp.join(' ')
            name="group: #{group}"+@@gindex.to_s
            gram=Gram.new(name,group)
            #gram.genProductions
            @@grams.push gram
            p=Production.new (gram.name)
            p.prodType= :gram
            p.initial=true if i==0
            p.final=true if i==array.length-1
            @productions.push p
            @@gindex+=1
            i=to+1
          else
            #error
            raise "error en ( ) gram"
          end
      when "|"
          @optionsGr=true
      else
          if (gram= search_gram elem)
            p=Production.new (gram.name)
            p.prodType= :gram
            p.initial=true if i==0
            p.final=true if i==array.length-1
            @productions.push p
          elsif (expr= Expr.search_expr (elem))

            if expr.name=='identificador'
               if (id=Expr.search_reserved (elem))
                 p=Production.new (elem)
                 p.prodType= :token
                 p.initial=true if i==0
                 p.final=true if i==array.length-1
                 @productions.push p
               else
                 p=Production.new (elem)
                 p.prodType= :token
                 p.initial=true if i==0
                 p.final=true if i==array.length-1
                 @productions.push p
               end

            else
            p=Production.new (elem)
            p.prodType= :token
            p.initial=true if i==0
            p.final=true if i==array.length-1
            @productions.push p
            end
          else
            #error
            raise "error en nombres gram"
          end


      end


      i+=1
    end
  end

  def gram? text
    for gram in @@grams
      return true if text==gram.name
    end
    return false
  end

  def search_gram text
    for gram in @@grams
      return gram if text==gram.name
    end
    return nil
  end

  def self.grams
    @@grams
  end

  def self.gram (name)
    for g in @@grams
      return g if name==g.name
    end
    return nil
  end

  @@gindex=0
  @@grams=[
    Gram.new( "archivo","defImportaciones? defclases? deffunciones? mainBloque terminacion finalArchivo"),
    Gram.new( "defImportaciones","gets inicioBloque importaciones? terminacion"),
    Gram.new( "importaciones","importacion importaciones?"),
    Gram.new( "importacion","importar (string|identificador) identificador? pcoma"),
    #Gram.new( "defroom","room identificador pcoma"),
    Gram.new( "defclases","modules inicioBloque clases? terminacion"),
    Gram.new( "clases","clase clases?"),
    Gram.new( "clase"," modulo identificador (parIni identificador parFin )? inicioBloque instrucciones? constructor? instrucciones? destructor? instrucciones? terminacion"),
    Gram.new( "constructor","make bloqueDec bloque"),
    Gram.new( "destructor","umake bloque"),
    Gram.new( "deffunciones","fns inicioBloque funciones? terminacion"),

    Gram.new( "funciones","funcion funciones?"),
    Gram.new( "funcion","decFn identificador bloqueDec  tipoRetorno tipoDato  bloque"),
    Gram.new( "bloqueDec","parIni declaraciones? parFin"),
    Gram.new( "mainBloque", "main  inicioBloque instrucciones?  "),
    Gram.new( "sbloque", "inicioBloque instrucciones? pcoma"),#/provicional
    Gram.new( "bloque", "inicioBloque instrucciones? terminacion  "),
    Gram.new( "declaraciones","declaracion declaraciones?"),
    Gram.new( "declaracion","definicion identificador inicio tipoDato opAsignacion"),#asignacion obligada
    Gram.new( "operacion","valor (oprMat operacion)?"),
    Gram.new( "valor","(identificador|llamadoFn|literal|grpOp)"),
    Gram.new( "grpOp","parIni operacion parFin"),
    Gram.new( "literal","(string|real|num|boolVal)"),
    Gram.new( "asignar","identificador opAsignacion"),
    Gram.new( "opAsignacion","asignacion operacion"),
    Gram.new( "instrucciones","instruccion instrucciones? "),
    Gram.new( "instruccion","instruccionpcoma |estructura"),
    Gram.new( "instruccionpcoma","instruccion1 pcoma"),
    Gram.new( "instruccion1","(declaracion|asignar|llamadoFn|estRetorno|defList)"),
    Gram.new( "estructura","(estPregunta|estLoop|estTloop|estCloop)"),
    Gram.new( "llamadoFn","parIni parametros? parFin"),
    Gram.new( "estRetorno","retorno operacion"),
    #Gram.new( "operaciones","operacion (oprMat operaciones)?"),
    Gram.new( "parametros","identificador (separador parametros)?"),
    Gram.new( "estPregunta","pregunta condiciones inicioBloque instrucciones? grpEstElif? estNif? terminacion"),
    Gram.new( "grpEstElif","estElif grpEstElif?"),
    Gram.new( "estElif","elif condiciones inicioBloque instrucciones?"),
    Gram.new( "estNif","nif inicioBloque instrucciones?"),
    Gram.new( "condiciones","condicion (oprLog condiciones)?"),
    Gram.new( "condicion","valor (oprComp valor)?"),
    Gram.new( "estLoop","loop identificador in iterable bloque"),
    Gram.new( "iterable","(identificador|estRango)"),
    Gram.new( "estRango","valor rango valor"),
    Gram.new( "estTloop","tloop declaraciones?  pcoma condiciones? pcoma instruccionSimple? bloque"),
    Gram.new( "estCloop","cloop condiciones tipoRetorno? bloque"),
    Gram.new( "ll","literal (separacion ll)?"),
    Gram.new( "defLista","list definicion identificador inicioBloque tipoDato asigLL?"),
    Gram.new( "asigLL","asignacion literalList"),
    Gram.new( "literalList","corchIni ll corchFin"),
    Gram.new( "defList","list identificador inicio tipoDato asigLL?"),
    Gram.new( "defTam","corchIni num corchFin"),
  ]
end
