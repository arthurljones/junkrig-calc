module Mast
  class PieceSet

    attr_reader :pieces, :length, :double_scarfed_pieces, :double_scarf_capacity

    def initialize(initial_pieces = Set.new)
      @pieces = Set.new
      @length = 0
      @double_scarfed_pieces = 0
      @double_scarf_capacity = -2

      add(initial_pieces) if initial_pieces.any?
    end

    def to_s
      "[#{pieces.to_a.join(", ")}]"
    end

    def add(new_pieces)
      @pieces.merge(new_pieces)
      @length += new_pieces.sum(&:length)
      double_scarfed_pieces = new_pieces.count(&:double_scarfed)
      @double_scarfed_pieces += double_scarfed_pieces
      @double_scarf_capacity += new_pieces.count - double_scarfed_pieces
    end

    def remove(old_pieces)
      @pieces.subtract(old_pieces)
      @length -= old_pieces.sum(&:length)
      double_scarfed_pieces = old_pieces.count(&:double_scarfed)
      @double_scarfed_pieces -= double_scarfed_pieces
      @double_scarf_capacity -= old_pieces.count - double_scarfed_pieces
    end
  end
end