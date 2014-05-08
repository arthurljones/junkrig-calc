module Mast
  class Stave < PieceSet
    MAX_SWAP_SET_SIZE = 2

    attr_reader :desired_unscarfed_length, :desired_length

    def initialize(initial = nil, desired_length = 0)
      super([])
      @swap_sets = Set[SwapSet.new([], self)]
      @desired_unscarfed_length = desired_length
      @desired_length = desired_unscarfed_length - SCARF_LENGTH
      if initial
        initial = PieceSet.new(initial) unless PieceSet === initial
        self << initial
      end
    end

    def to_s
      "Stave (#{desired_unscarfed_length}#{"%+i" % extra_length}in #{super})"
    end

    def <<(other)
      other = coerce(other)
      other.pieces.each do |piece|
        size_range = 0..(MAX_SWAP_SET_SIZE - 1)
        combinations = size_range.collect{ |size| pieces.to_a.combination(size).to_a}.flatten(1)
        @swap_sets += combinations.map{ |combo| SwapSet.new(combo << piece, self) }
        super([piece])
      end
    end

    def >>(other)
      other = coerce(other)
      @swap_sets.delete_if{ |set| set.pieces.intersect?(other.pieces) }
      super(other)
    end

    def unique_swap_sets
      used = Set.new
      result = []
      @swap_sets.each do |set|
        key = [set.length, set.pieces.count, set.double_scarfed_pieces]
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