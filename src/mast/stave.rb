module Mast
  class Stave < PieceSet
    MAX_SWAP_SET_SIZE = 2

  protected

    attr_accessor :swap_sets, :name

  public

    attr_reader :desired_unscarfed_length, :desired_length

    def initialize(initial = nil, desired_length = 0, name = "?")
      super([])
      @name = name
      @swap_sets = Set[SwapSet.new([], self)]
      @desired_unscarfed_length = desired_length
      @desired_length = desired_unscarfed_length - SCARF_LENGTH
      self << coerce(initial) if initial
    end

    def to_s
      "Stave #{name} (#{desired_unscarfed_length}#{"%+i" % extra_length}in #{super})"
    end

    def <<(other)
      if @swap_sets
        other = coerce(other)
        other.pieces.each do |piece|
          unless piece.locked?
            size_range = 0..(MAX_SWAP_SET_SIZE - 1)
            combinations = size_range.collect{ |size| pieces.to_a.combination(size).to_a}.flatten(1)
            @swap_sets += combinations.map{ |combo| SwapSet.new(combo << piece, self) }
          end
          super([piece])
        end
      else
        super
      end
    end

    def >>(other)
      if @swap_sets
        other = coerce(other)
        @swap_sets.delete_if{ |set| set.pieces.intersect?(other.pieces) }
      end
      super(other)
    end

    def for_results
      result = super
      result.swap_sets = nil
      result
    end

    def unique_swap_sets
      used = Set.new
      result = []
      @swap_sets.each do |set|
        key = [set.length, set.count, set.double_scarfed_pieces]
        key.sort!
        result << set if used.add?(key)
      end
      result
    end

    def actual_unscarfed_length
      length + SCARF_LENGTH * count
    end

    def extra_length
      length - desired_length
    end
  end
end