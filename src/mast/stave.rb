module Mast
  class Stave < PieceSet
    MAX_SWAP_SET_SIZE = 3

    attr_reader :desired_unscarfed_length, :desired_length

    def initialize(desired_length)
      super(Set.new)
      @desired_unscarfed_length = desired_length
      @desired_length = desired_unscarfed_length - SCARF_LENGTH
      @swap_sets = Set.new
    end

    def to_s
      "Stave (#{desired_length}#{"%+i" % extra_length}in #{super})"
    end

    def add(new_pieces)
      new_pieces.each do |piece|
        size_range = 1..(MAX_SWAP_SET_SIZE - 1)
        combinations = size_range.collect{ |size| pieces.to_a.combination(size).to_a}.flatten(1)
        @swap_sets += combinations.map{ |combo| SwapSet.new(combo << piece, self) }
        super([piece])
      end
    end

    def remove(old_pieces)
      @swap_sets.delete_if{ |set| set.pieces.intersect?(old_pieces) }

      super(old_pieces)
    end

    def unique_swap_sets
      used = Set.new
      result = []
      @swap_sets.each do |set|
        key = set.pieces.collect{ |piece| [piece.length, piece.double_scarfed ? 1 : 0] }
        key.sort!
        result << set if used.add?(key)
      end
      result
    end

    def actual_unscarfed_length
      length + SCARF_LENGTH * pieces.count
    end

    def extra_length
      length - desired_length
    end
  end
end