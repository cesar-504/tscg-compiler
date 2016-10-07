
class P < Struct.new( :palabra ,:opcional, :grupo , :conop, :tipo ,:opciones) do
  def initialize(*)
    super
    self.opcional ||= false
    self.grupo ||=false
    self.opciones ||=[]
    self.conop=false
    self.conop = true if opciones.count>0
  end
end

class Gram
  @@gindex=0
  def initialize(nombre,produccion)
        @nombre=nombre
        @produccion=produccion
  end

  def genPs (grupo=false)
    sep = grupo ? "," : " "
    array = @produccion.split(sep)

    for x in array
      op=false
      gr=false
      conop=false
      opciones=[]
      if(x[-1, 1]=="?")
        op=true
        x.chop!
      end
      if(x[0]=="(" and x[-1,1]==")")
        x[0]=""
        x.chop!
        nnom="grupo"+@@gindex
        @@gindex+=1
        tmp=Gram.new(nnom,x)
        x=nnom
        @@grams.push(tmp)
        tmp.genPs(true)
      else
        arrayOp= x.split("|")
        if(arrayOp.count>1)
          conop=true
          for o in arrayOp
            opciones.push(P.new(o,ckTipo(o) ) )
          end
        end
      end
      Ps.push(P( (x,conop ? "grOp" : ckTipo(x)) , op , gr ,opciones ))
    end
  end

  def ckTipo(pal)
    for(gram in @@grams)
        if(pal==gram.nombre)
          return "gramatica"
        end

    end
    for exp in Expr.exprs
      if (pal==exp.name)
        return "token"
      end
    end
    for exp in Expr.reserved
      if pal==exp.name
        return "token"
      end
    end
    return "desconocido"
  end

  def self.isGram(pal)
    i=0
    for g in @@grams
      i+=1
      if pal==g.nombre
        return i-1
      end
    end
    return -1
  end

  @@grams=[
    Gram.new( "archivo","defImportaciones? defroom? defclases? deffunciones? mainBloque"),
    Gram.new( "defImportaciones","gets inicio salto importaciones? terminacion"),
    Gram.new( "importaciones","importacion importaciones?"),
    Gram.new( "importacion","importar (string|identificador) identificador? salto"),
    Gram.new( "defroom","room identificador salto"),
    Gram.new( "defclases","modules inicio salto clases? terminacion"),
    Gram.new( "clases","clase clases?"),
    Gram.new( "clase","modificadores? modulo identificador (parIni,identificador,parFin)? inicio salto instrucciones? constructor? instrucciones? destructor? instrucciones? terminacion"),
    Gram.new( "constructor","make bloqueDec bloque"),
    Gram.new( "destructor","umake bloque"),
    Gram.new( "deffunciones","fns inicio salto funciones? terminacion"),
    Gram.new( "funciones","funcion funciones?"),
    Gram.new( "funcion","modificadores? decFn identificador bloqueDec  tipoRetorno tipoDato  bloque"),
    Gram.new( "bloqueDec","parIni declaraciones? parFin"),
    Gram.new( "mainBloque", "main  bloque"),
    Gram.new( "sbloque", "inicio salto instrucciones? salto"),#/provicional
    Gram.new( "bloque", "inicio salto instrucciones? terminacion  "),

    Gram.new( "prueba","inicio terminacion? salto"),
    Gram.new( "prueba2"," prueba? inicio"),
    Gram.new( "prueba3","terminacion (salto|terminacion)"),


    Gram.new( "modificadores","modificador modificadores?"),
    Gram.new( "declaraciones","declaracion declaraciones?"),
    Gram.new( "declaracion","modificadores? definicion identificador inicio tipoDato opAsignacion?"),

    Gram.new( "operacion","valor oprMat valor"),

    #Gram.new( "operacionUni","((id,opeUni)|(opeUni,id))"),

    Gram.new( "valor","(identificador|llamadoFn|literal|grpOp)"),
    Gram.new( "grpOp","parIni operaciones parFin"),
    Gram.new( "literal","(string|numero|boolVal)"),
    Gram.new( "aux1","identificador"),
    Gram.new( "asignar","identificador opAsignacion"),
    Gram.new( "operacionUni","identificador opUnit"),
    Gram.new( "opAsignacion","(asignacion|op+igual) (valor|operacines)"),
    Gram.new( "instrucciones","instruccion instrucciones?"),
    #  Gram.new( "sinstruccion","()"),#quite estructura
    Gram.new( "instruccionSimple","operacionUni|asignar"),#quite estructura
    Gram.new( "instruccion","(declaracion|asignar|estructura|llamadoFn|estRetorno|interrupcion|defEvento|emitir|conectar|defArray|defList) salto"),
    Gram.new( "estructura","estPregunta|estLoop|estTloop|estCloop|estNor|estRouter"),#para prueba
    Gram.new( "declaracion","modificadores? definicion identificador inicio tipoDato opAsignacion?"),#para prueba

    Gram.new( "llamadoFn","parIni parametros? parFin salto"),
    Gram.new( "estRetorno","retorno (valor|operacines)?"),
    Gram.new( "operaciones","(operacionUni|operacion) (oprMat,operaciones)?"),

    Gram.new( "parametros","identificador"),#falta

    Gram.new( "estPregunta","pregunta condiciones bloque grpEstElif? estNif? "),
    Gram.new( "grpEstElif","estElif grpEstElif?"),
    Gram.new( "estElif","elif condiciones bloque"),#falta else if extras
    Gram.new( "estNif","nif bloque"),
    Gram.new( "condiciones","condicion (oprLog,condiciones)?"),
    Gram.new( "condicion","valor (oprComp,valor)?"),
    Gram.new( "estLoop","loop identificador in iterable bloque"),
    Gram.new( "iterable","identificador|estRango"),
    Gram.new( "estRango","valor rango valor"),
    Gram.new( "estTloop","tloop declaraciones?  terminacionSimple condiciones? terminacionSimple instruccionSimple? bloque"),
    Gram.new( "estCloop","cloop condiciones tipoRetorno? bloque"),
    Gram.new( "estRouter","router valor inicio salto ports? estNotport salto? terminacion"),
    Gram.new( "ports","estPort instrucciones? ports?"),
    Gram.new( "estPort","port ll bloque"),
    Gram.new( "ll","literal (separacion,ll)?"),
    Gram.new( "estNotport","notPort bloque"),
    Gram.new( "estNor","capError bloque ports estRest terminacion"),
    Gram.new( "estRest","rest bloque"),
    Gram.new( "defLista","list definicion identificador inicio tipoDato asigLL?"),
    Gram.new( "asigLL","asignacion literalList"),
    Gram.new( "literalList","corchIni ll corchFin"),
    Gram.new( "defEvento","signal identificador literalList "),
    Gram.new( "emitir","emit identificador"),
    Gram.new( "conectar","identificador link llamadoFn"),
    Gram.new( "defArray","array  identificador inicio tipoDato (asigLL|defTam)"),
    Gram.new( "defList","list identificador inicio tipoDato asigLL?"),
    Gram.new( "defTam","corchIni numero corchFin"),
  ]

  def self.grams
    @@grams
  end
  

end