
class MCodeGen
    def initialize tree     
        @tree=tree
        @fIni=[]
        @fEnd=[]
        @t=0
        
    end
    def nextNode
        @tree.each do |item|
            if item.children.count==0 
                n= item.dclone
                p=item.parent
                p.remove!(item)
                return n
            end
        end    
    end    
    def genFile 
        File.open("./ejemplos/main.m","w") do |f| 
        
            @tree.postordered_each do |item|
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
        puts
        array.shift
        result=nil
    
        array = PostFix.infix_to_posfix  array 
        print_pfix array , node[1]
        puts 
    end

    def pr_estPregunta node
        array =PostFix.infix_to_posfix node_to_array(node.children[1])
        var= print_pfix array
        @fIni<< "if #{var}==false goto nif#{@t}"
        @fEnd<< "end_if#{@t}"

    end
    def pr_estNif node
        @fIni<<"goto end_if#{@t}"
        @fIni<< "nif#{@t}:"
        
        puts
    end
    def pr_asignar node
        puts node.children
        array = node_to_array  node[1]
        puts array
        array.shift
        result=nil
    
        array = PostFix.infix_to_posfix  array 
        print_pfix array , node[0]
        puts
    end
    def pr_estCloop node
        array =PostFix.infix_to_posfix node_to_array(node.children[1])
        var= print_pfix array
        @fIni<<var
        @fIni<<"cloop#{@t}: /////////"

    end
    

    def instrucciones_to_array node
        i=0
        tmp = node
        array=[]
        puts tmp[i]
        while i<tmp.children.count
            if tmp.children[i].name[/ .+ /].to_s.strip == "instruccion"
                array<<tmp.children[i] 
                i+=1
            elsif tmp.children[i].name[/ .+ /].to_s.strip == "instrucciones"
                tmp=tmp.children[i]
                i==0
            end 
        end
        array
    end

    
    def print_pfix tokens , resultToken=nil
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
            if resultToken
                @fIni<< "#{resultToken.content.val} = t_#{@t-1}" 
                return resultToken
            end
            "t_#{@t-1}"
        end
    end

end