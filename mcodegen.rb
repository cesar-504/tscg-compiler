
class MCodeGen
    def initialize tree     
        @tree=tree
        @fIni=[]
        @fEnd=[]
        @t=0
        
    end

    def genFile 
        File.open("./ejemplos/main.m","w") do |f| 
        
            @tree.each do |item|  
                begin
                    
                    send "pr_"+item.name[/ .+ /].to_s.strip,item
                rescue NoMethodError 
                end
               
            
               
            
            

            end
            @fIni.each { |i|  f.puts  i }
            @fEnd.reverse_each{ |i|  f.puts  i }
      end
        
    end

    def node_to_array node
        array=[]
        node.each { |n| array<< n.content if n.children.count==0 }
        array
    end

    def pr_mainBloque node
        
        @fIni<<"mainBloque:"
        @fEnd<<"mainBloque end"
    end

    def pr_declaracion node
        puts
    end
    def pr_declaracion node
        array = node_to_array  node[4]
       
        array.shift
        result=nil
    
        array = PostFix.infix_to_posfix  array 
        print_pfix array , node[1]
        puts 
    end
    def print_pfix tokens , resultToken
        i=0
        File.open("./ejemplos/main.m","a") do |f|
            if tokens.count==1
                @fIni<< "#{resultToken.content.val} = #{tokens[0].val}"
                return
            end
            while i<tokens.count
                case tokens[i].val 
                when "+","*","-",">","<",">=","<=","==","!=","&&","||"
                    @fIni<< "t_#{@t} =  #{tokens[i-2].val} #{tokens[i].val} #{tokens[i-1].val}"
                    
                    tokens.delete_at(i-2)
                    tokens.delete_at(i-2)
                    tokens[i-2].val="t_"+@t.to_s
                    i=i-2
                    @t+=1
                end
                i+=1
            end
                @fIni<< "#{resultToken.content.val} = t_#{@t-1}" 
            
                
            
            puts
        end
    end

end