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
      else
        self.pieces = Set.new(initial)
        self.count = pieces.count
        self.raw_length = pieces.sum(&:length)
        self.double_scarfed_pieces = pieces.count(&:double_scarfed)
      end
    end

    def length
      scarf_loss_count = count - 1 + [double_scarf_extra, 0].max
      raw_length - scarf_loss_count * SCARF_LENGTH
    end

    def double_scarf_extra
      double_scarfed_pieces + 2 - count
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