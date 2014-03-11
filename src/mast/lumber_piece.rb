module Mast
  class LumberPiece
    attr_reader :unscarfed_length, :length, :double_scarfed

    def initialize(length, double_scarfed = false)
      @unscarfed_length = length
      @length = length - SCARF_LENGTH
      @double_scarfed = double_scarfed
      @to_s = "#{unscarfed_length}in"
      @to_s += "-D" if double_scarfed
    end

    def self.init_many(lengths, double_scarfed = false)
      lengths.collect{ |length| new(length, double_scarfed) }
    end

    def to_s
      @to_s
    end

    def <=>(other)
      result = length <=> other.length
      result = double_scarfed <=> other.double_scarfed if result == 0
      result
    end
  end
end