module Mast
  class Stave < PieceSet
    MAX_SWAP_SET_SIZE = 2

    attr_reader :desired_unscarfed_length, :desired_length, :swap_sets

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
        size_range = 1..MAX_SWAP_SET_SIZE
        new_swaps = size_range.collect{ |size| pieces.to_a.combination(size).map{ |combo| combo << piece }}.flatten(1)
        @swap_sets += new_swaps.collect{ |set| SwapSet.new(set, self) }
      end
      #@swap_sets.sort_by!(&:length)

      super(new_pieces)
    end

    def remove(old_pieces)
      @swap_sets.delete_if{ |set| set.pieces.intersect?(old_pieces) }

      super(old_pieces)
    end

    def actual_unscarfed_length
      length + SCARF_LENGTH * pieces.count
    end

    def extra_length
      length - desired_length
    end
  end
end