class MCodeGen
    def initialize tree
        @tree=tree
        @fIni=[]
        @fEnd=[]
        @t=0
        @nextNode=nil

    end
    def correctNode? node
        node.children.each { |e| return false if !e.b   }
        true
    end

<<<<<<< HEAD
  
    def genFile 
        File.open("./ejemplos/main.m","w") do |f| 
        
=======

    def genFile
        File.open("./ejemplos/main.m","w") do |f|

>>>>>>> 57db2786fe4ecc2cf1eb3fdd40d5c8e46fa82f51
            @tree.each do |item|
                puts item.name
                begin

                    send "pr_"+item.name[/ .+ /].to_s.strip,item
                rescue NoMethodError
                end
<<<<<<< HEAD
               
            
               
            
            
 
=======






>>>>>>> 57db2786fe4ecc2cf1eb3fdd40d5c8e46fa82f51
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
       #@fIni.unshift "mainBloque:"
       #@fIni << "mainBloque end"
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
        dec="mem "
        puts "mem"
        puts node.children
        dec+=node[1].content.val
        dec+=" "

        case node[3].content.val
        when "num"
          dec+="32"
        when "float"
          dec+="32"
        when "real"
          dec+="64"
        when "bool"
          dec+="8"
        when "string"
          dec+="16"
        end
        @fIni<<dec
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
        #puts node.children
        array = node_to_array  node[1]
        #puts array
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
<<<<<<< HEAD
        @fIni<<"cloop#{@t}: /////////"
=======
        @fIni<<"cloop#{@t}:"
>>>>>>> 57db2786fe4ecc2cf1eb3fdd40d5c8e46fa82f51
        @fIni<< "if #{var}==false goto end_cloop#{@t}"
        @fEnd<<"end_cloop#{@t}"
        @t+=1
    end


    def instrucciones_to_array node
        i=0
        tmp = node
        array=[]
        #puts tmp[i]
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
                if resultToken
<<<<<<< HEAD
                    @fIni<< "#{resultToken.content.val} = #{tokens[0].val}"
                else
=======

                    @fIni<< "#{resultToken.content.val} = #{tokens[0].val}"
                else

>>>>>>> 57db2786fe4ecc2cf1eb3fdd40d5c8e46fa82f51
                    @fIni<< "t_#{@t} = #{tokens[0].val}"
                    @t+=1
                    return "t_#{@t}"
                end
                return
            end
            while i<tokens.count
                case tokens[i].val
                when "+","*","-",">","<",">=","<=","==","!=","&&","||"
                    @fIni<<"s"
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
