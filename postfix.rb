require_relative 'token'
class PostFix
    def self.infix_to_posfix tokens
        stack = []
    out=[]
    prec ={
      "^"=>10,
      "*"=>9,
      "/"=>9,
      "+"=> 7,
      "-"=>7,
      "("=>5,
      "<"=>4,
      ">"=>4,
      "<="=>4,
      ">="=>4,
      "=="=>3,
      "!="=>3,
      "&&"=>2,
      "||"=>1
    }
    assoc ={
      "^":'r',
      "*":'l',
      "/":'l',
      "+":'l',
      "-":'l',
      "(":'l'
    }
    sumOp=0
    sumVar=0
    error=false
    #puts tokens
    puts
     i=0
    for t in tokens
    #puts t
      if (t.name=="num" or t.name=="real") or t.name=="identificador" or t.name=="string" or t.name=="boolVal"
        sumVar+=1
        out.push t
      elsif t.val == "("
        stack.push t
      elsif t.val==")"
        while stack.last.val != "("
          if !stack.last
            abort "error: falta: (. #{t.noLine}:#{t.noColumn}" 
            error=true
            break;
          end
          out.push stack.pop  
          
        end
        stack.pop if stack.last.val=="("
      elsif t.name=="oprMat" or t.name=="oprComp"  or t.name=="oprLog"
        sumOp+=1
        out.push stack.pop while stack.last and prec[stack.last.val] >= prec[t.val]
        
        stack.push t
      else
        abort  "error: inesperado: #{t.name }. #{t.noLine}:#{t.noColumn}"
        error=true
        break;
      end
      i+=1
    end
    stack.each{|item| abort  "error: falta: ). #{t.noLine}:#{t.noColumn}" if item.val=="("} if stack
    
      
    if sumOp!=sumVar-1 or (sumOp==0 and sumVar==0)
       abort "error: numero de operadores y operandos no corresponde. "
    elsif !error
      stack.reverse.each{ |op| out.push op }
      return out
    end
    end
end

