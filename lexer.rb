class Lexer
  #file.each_line
  #file.getc
  #file.readlines[2]
  #file.eof?
  #file.ungetc h
  #file.rewind

  def initialize(file_url)
    @file_url =file_url
    @nline=0
    @ncolumn=0
    @b=true
    #@file =File.open(file_url,"r")
    @file =File.open("/home/cesar/Documentos/Proyectos/ruby/tscg-compiler/ejemplos/main.tscg", "r")
  end

  def first()
    #code
  end

  def next_token()

      #puts @nline
      #puts @line
      if @line=="" or !@line
        @nline+=1 if !@b
        @b=false
        @file.rewind
        @line = @file.readlines[@nline]
      end
      #puts @line

      while @line && @line.length>0
        for expr in Expr.exprs
          #return token if token!=nil
          match = expr.regex.match(@line)
          if match
            case expr.name
            when 'espacio','comentario'#,'comentariob'
              @line=@line[match.end(0)..-1]
              return next_token

            when 'opUnit','oprMat','oprComp','oprLog'
              @line=@line[match.end(0)..-1]
              return Token(expr.name,match[0],match[0],@nline)
            when 'otro'
              @line=@line[match.end(0)..-1]
              puts "token desconocido: "+match[0]
              return nil
            when 'identificador'
              @line=@line[match.end(0)..-1]

              for id in Expr.reserved
                match2 = id.regex.match(match[0])
                if match2
                  return Token(id.name,match[0],match[0],@nline)

                end

              end
              num=@simTable.add_d(match[0])
              return Token(expr.name,num,match[0],nline)
            when 'numero'
              @line=@line[match.end(0)..-1]
              return Token(expr.name,match[0],match[0],@nline)
            else
              @line=@line[match.end(0)..-1]
             return Token(expr.name,match[0],match[0],@nline)
            end

          end
        end
        return nil
      end

      return nil


  end
end
