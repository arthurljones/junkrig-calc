module Mast
  class PieceSet
  protected
    attr_accessor :pieces, :count, :raw_length, :double_scarfed_pieces, :double_scarf_capacity

  public
    attr_reader :pieces, :count, :double_scarfed_pieces, :double_scarf_capacity

    def initialize(initial)
      if PieceSet === initial
        self.pieces = Set.new(initial.pieces) if initial.pieces
        self.count = initial.count
        self.raw_length = initial.raw_length
        self.double_scarfed_pieces = initial.double_scarfed_pices
        self.double_scarf_capacity = initial.double_scarfed_capacity
      else
        self.pieces = Set.new(initial)
        self.count = pieces.count
        self.raw_length = pieces.sum(&:length)
        self.double_scarfed_pieces = pieces.count(&:double_scarfed)
        self.double_scarf_capacity = pieces.length - (double_scarfed_pieces + 2)
      end
    end

    def length
      len = @raw_length
      len += @double_scarf_capacity * SCARF_LENGTH if @double_scarf_capacity < 0
      len
    end

    def to_s
      "[#{pieces.to_a.join(", ")}]"
    end

    def +(other)
      new(self) << other
    end

    def -(other)
      new(self) >> other
    end

    def <<(other)
      other = coerce(other)
      if pieces && other.pieces
        raise "Attempting to add pieces that are present" unless pieces.disjoint?(other.pieces)
        pieces.merge(other.pieces)
      end
      self.raw_length += other.raw_length
      self.count += other.count
      self.double_scarfed_pieces += other.double_scarfed_pieces
      self.double_scarf_capacity += other.double_scarf_capacity + 2
      self
    end

    def >>(other)
      other = coerce(other)
      if pieces && other.pieces
        raise "Attempting to add pieces that are present" unless other.pieces.subset?(pieces)
        pieces.subtract(other.pieces)
      end
      self.raw_length -= other.raw_length
      self.count -= other.count
      self.double_scarfed_pieces -= other.double_scarfed_pieces
      self.double_scarf_capacity -= other.double_scarf_capacity + 2
      self
    end

    def for_results
      result = self.dup
      result.pieces = nil
      result
    end

  protected

    def coerce(other)
      PieceSet === other ? other : PieceSet.new(other)
    end

  end
end