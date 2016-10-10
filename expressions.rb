class Expr
  attr_accessor :name,:regex
  def initialize(name,regex)
    @name=name
    @regex=regex
  end


  @@exprs=[
    Expr.new('salto',/^\n/ ),
    Expr.new("espacio", /^\ +/ ),
    Expr.new("identificador", /^[a-zA-Z_]\w*/ ),#150
    #Expr.new('agrupacion',/^[\\[\\]\\{\\}\\[\\]\\(\\)]/),
    Expr.new('corchIni', /^\[/ ),
    Expr.new('corchFin', /^\]/ ),
    Expr.new('llaveIni', /^\{/ ),
    Expr.new('llaveFin', /^\}/ ),
    Expr.new('parIni', /^\(/ ),
    Expr.new('parFin', /^\)/ ),

    #Expr.new("string", /^\"[^\"]*\"|^\'[^\']*\'/ ),
    Expr.new("string", /^\"[^\"\\\r\n]*(?:\\.[^"\\\r\n]*)*"|^'[^'\\\r\n]*(?:\\.[^'\\\r\n]*)*'/ ),
    Expr.new("comentario", /^#.*\n/ ),
    Expr.new("comentariob", /^@>[^(<@)]*<@/ ),
    #Expr.new("comentarioc", /^@>[^(<@)]*<@/ ),
    Expr.new("tipoRetorno", /^->/ ),
    Expr.new("retorno", /^<</ ),
    Expr.new("elif", /^\?:|^:if/ ),
    Expr.new("nif", /^!:|^nif/ ),
    Expr.new("op+igual", /^\+=|^-=|^\*=|^\*\*=|^iz=/ ),
    Expr.new("opUnit", /^\+\+|^--/ ),
    Expr.new("oprMat", /^\/\/|^\*\*/),
    Expr.new("oprMat", /^-|^\+|^\/|^%|^\*|^\^/ ),
    Expr.new("oprComp", /^<=|^>=|^!=|^==|^<\?|^!<\?|^\?>|^!\?>/ ),
    Expr.new("oprComp", /^<|^>/ ),
    Expr.new("oprLog", /^&&|^\|\||^!/ ),
    Expr.new("asignacion", /^=/ ),
    Expr.new("pregunta", /^\?:/ ),#50
    Expr.new("rango", /^\.\.\./ ),
    Expr.new("puntuacion", /^\./ ),
    Expr.new("terminacion", /^;;/ ),
    Expr.new("terminacionSimple", /^;/ ),
    Expr.new("separacion", /^,/ ),
    Expr.new("inicio", /^:/ ),

    Expr.new("self", /^\$/ ),
    #Expr.new("numero", /^((\d+)?\.\d+)[eE][+-]?\d+\W/ ),
    Expr.new("numero", /^((\d+)?\.\d+)([eE][+-]?\d+)?/ ),
    Expr.new("numero", /^\d+/ ),

    Expr.new("crear", /^~/ ),



    Expr.new("otro", /[\s;,.!#%^*(){}\[\]+=<>\-]|@>/ ),

  ]

  @@reserved=[
    Expr.new("in", /^in$/ ),
    Expr.new("router", /^router$/ ),
    Expr.new("preguntaMult", /^router$/ ),
    Expr.new("loop", /^loop$/ ),
    Expr.new("tloop", /^tloop$/ ),
    Expr.new("cloop", /^cloop$/ ),
    Expr.new("interrupcion", /^next$|^stop$/ ),
    Expr.new("port", /^port$/ ),
    Expr.new("notPort", /^notport$/ ),
    Expr.new("definicion", /^def$|^var$/ ),
    Expr.new("modulo", /^mod$/ ),
    Expr.new("modificador", /^sinsig$|^free$|^lock$|^mable$|^ever$|^ext$|^shield$/ ),
    Expr.new("signal", /^signal$/ ),
    Expr.new("list", /^list$/ ),
    Expr.new("array", /^array$/ ),
    Expr.new("emit", /^emit$/ ),
    Expr.new("link", /^link$/ ),
    Expr.new("dentro", /^in$/ ),
    Expr.new("data", /^data$/ ),
    Expr.new("padre", /^parent$/ ),
    Expr.new("decFn", /^fn$/ ),
    Expr.new("tipoDato", /^ul$|^num$|^text$|^decimal$|^real$|^bool$|^enum$|^vec2d$|^vec3d$|^vec4d$|^group$|^bites$|^list$|^cad$|^dic$|^item$|^snum$|^sdecimal$|^sreal$/ ),
    Expr.new("boolVal", /^true$|^false$|^yes$|^no$/ ),#101
    Expr.new("room", /^room$/ ),
    Expr.new("null", /^nul$/ ),
    Expr.new("pregunta", /^if$/ ),
    Expr.new("tul", /^tul$/ ),
    Expr.new("capError", /^nor$/ ),
    Expr.new("rest", /^rest$/ ),
    Expr.new("tipovar", /^itype$/ ),
    Expr.new("cast", /^to$/ ),
    Expr.new("case",/ ^case$/ ),
    Expr.new("constante", /^let$/ ),
    Expr.new("aleatorio", /^rand$/ ),
    Expr.new("default", /^default$/ ),
    Expr.new("tamaño", /^isize$/ ),
    Expr.new("tris", /^gsen$|^gcos$|^gtan$|^gcot$|^gsec$|^gcsec$|^gvers$|^gcover$|^rsen$|^rcos$|^rtan$|^rcot$|^rsec$|^rcsec$|^rvers$|^rcover$/ ),
    Expr.new("infinito", /^sinfin$/ ),
    Expr.new("pi", /^pi$/ ),#130
    Expr.new("euler", /^meu$/ ),
    Expr.new("logaritmo", /^ln$/ ),
    Expr.new("make", /^make$/ ),
    Expr.new("umake", /^umake$/),

    Expr.new("potencia", /^wer$/ ),
    Expr.new("raiz", /^iz$/ ),
    Expr.new("salida", /^out$|^outln$|^print$|^println$/ ),
    Expr.new("entrada", /^inp$/ ),
    Expr.new("crear", /^new$/ ),
    Expr.new("tiempo", /^wait$/ ),
    Expr.new("hora", /^time$/ ),
    Expr.new("fecha", /^today$/ ),
    Expr.new("borrar", /^del$/ ),
    Expr.new("importar", /^get$|^import$/ ),
    Expr.new("gets", /^gets$/ ),
    Expr.new("modules", /^modules$/ ),
    Expr.new("fns", /^fns$/ ),
    Expr.new("main", /^main$/ ),
  ]

  def self.exprs
    @@exprs
  end
  def self.reserved
    @@reserved
  end
  def self.search_reserved (idToken)
    for expr in @@reserved
        return expr if expr.regex.match(idToken)
    end
    return nil
  end
  def self.search_expr (idToken)
    for expr in @@exprs
        return expr if expr.regex.match(idToken)
    end
    return nil
  end



end
