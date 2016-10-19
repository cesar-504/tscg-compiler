Token=Struct.new(:name , :attr , :val,:noLine,:noColumn)do
  def ==(other)
    @val==other.val and @name==other.name
  end
end
