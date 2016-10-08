class SimTable
  def initialize()
    @sim_table=[]
  end

  def exist_in_table?(id)
    for item in @sim_table
      return true if item==id
    end
    return false
  end
  def index_of(id)
    i=0
    for item in @sim_table
      return i if item==id
      i+=1
    end
    return nil
  end
  def add_id(id)
    if !exist_in_table?( id)
      @sim_table.push id
      return @sim_table.count-1
    end
    return index_of id

  end
end
