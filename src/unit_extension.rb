module RubyUnits
  class Unit
    def to_s_with_flatten(*args, &block)
      to_s_without_flatten(*args, &block).gsub(/ /, '')
    end
    alias_method_chain(:to_s, :flatten)
  end
end