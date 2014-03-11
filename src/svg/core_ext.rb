class Set
  def to_s
    "Set[#{to_a.join(", ")}]"
  end
  end

class Array
  def to_s
    "[#{to_a.join(", ")}]"
  end
end