class Set
  def to_s
    "Set[#{to_a.join(", ")}]"
  end
end

class Array
  def to_s
    "[#{join(", ")}]"
  end

  def subtract!(other)
    other.select do |elem|
      index = index(elem)
      delete_at(index) if index
      index
    end
  end
end

module RubyUnits
  class Unit
    def to_s_with_flatten(*args, &block)
      to_s_without_flatten(*args, &block).gsub(/ /, '')
    end
    alias_method_chain(:to_s, :flatten)
  end
end
