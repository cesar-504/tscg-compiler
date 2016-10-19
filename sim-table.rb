class SimTable

  def initialize
    @sim_table=[]
  end

  def exist_in_table? token
    return true if index_of token
    false
  end

  def index token
    @sim_table.each_with_index {|item, i| return i if item==token}
    nil
  end

  def add_token token
    if (i=index token) then return i end
      @sim_table.push token
      @sim_table.count-1
  end


end
