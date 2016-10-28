SymbolStr=Struct.new(:name,:ctype,:stype)do
  def ==(other)
    @name==other.name
  end
end


class SymTable

  def initialize
    @sim_table=[]
  end

  def exist_in_table? symbol
    return true if index symbol
    false
  end

  def index symbol
    
    @sim_table.each_with_index {|item, i| return i if item.name==symbol.name}
    nil
  end

  def add_symbol symbol
    if (i=index symbol) then return i end
      @sim_table.push symbol
      @sim_table.count-1
  end


end
