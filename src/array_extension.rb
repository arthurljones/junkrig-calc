class Array
  def subtract!(other)
    other.select do |elem|
      index = index(elem)
      delete_at(index) if index
      index
    end
  end
end
