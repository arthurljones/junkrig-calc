module Mast
  class SwapSet < PieceSet
    attr_accessor :owner

    def initialize(pieces, owner)
      super(pieces)
      @owner = owner
    end

    def test_swap(other)
      result = owner.for_results
      result >> self
      result << other
      result
    end

    def swap(other)
      owner >> self
      other.owner >> other

      owner << other
      other.owner << self
    end
  end
end