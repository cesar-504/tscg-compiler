class Lexer
  #file.each_line
  #file.getc
  #file.readlines[2]
  #file.eof?
  #file.ungetc h
  #file.rewind
  require_relative 'token'
  require_relative 'sim-table'
  require 'terminal-table'

  def initialize(file_url)
    @file_url =file_url
    @nline=0
    @columnSum=1
    @file =File.open(file_url, "r")
    @sim_table=SimTable.new
  end

  def next_token()
    if !@line or @line==""
      @nline+=1
      @file.rewind
      @line = @file.readlines[@nline-1]
      @columnSum=1
    end

    while @line && @line.length>0
      for expr in Expr.exprs
        if match= expr.regex.match(@line)
          ncolumn=@columnSum
          @line=@line[match.end(0)..-1]
          @columnSum+=match.end(0)
          case expr.name
          when 'espacio','comentario'#,'comentariob'
            return next_token
            # when 'otro'
            #   puts "token desconocido: "+match[0]
            #   return nil
          when 'identificador'
            if (id = Expr.search_reserved match[0])
              return Token.new(id.name,nil,match[0],@nline,ncolumn)
            end
            num=@sim_table.add_id(match[0])
            return Token.new(expr.name,num,match[0],@nline,ncolumn)
          end
          return Token.new(expr.name,nil,match[0],@nline,ncolumn)
        end
      end
      return nil
    end
    return nil
  end

  def to_s
    Terminal::Table.new do |t|
      t<<['no','token','attr','val','noline','nocolumn']
      t<<:separator
      token=next_token
      i=1
      while token do
        t<<[i,token.name,token.attr,token.val,token.noLine,token.noColumn]
        token=next_token
        i+=1
      end
      return t.to_s
    end
  end
end
