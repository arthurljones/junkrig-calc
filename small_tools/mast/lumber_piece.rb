module Mast
  class LumberPiece
    NOMINAL_DIFFERENCE = 2 #inches

    attr_reader :unscarfed_length, :length, :double_scarfed

    def initialize(length, double_scarfed = false)
      @unscarfed_length = length
      @length = length - NOMINAL_DIFFERENCE
      @double_scarfed = double_scarfed
      @to_s = "#{unscarfed_length}in"
      @to_s += "-D" if double_scarfed
    end

    def self.init_many(lengths, double_scarfed = false)
      lengths.collect{ |length| new(length, double_scarfed) }
    end

    def to_s
      @to_s #+ (locked? ? "(L)" : '')
    end

    def inspect
      to_s
    end

    def <=>(other)
      length <=> other.length || (double_scarfed ? 1 : 0) <=> (other.double_scarfed ? 1 : 0)
    end

    def locked?
      @locked
    end

    def lock
      @locked = true
    end

    def unlock
      @locked = false
    end
  end
end
