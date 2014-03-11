module Mast
  class SwapSet < PieceSet
    attr_accessor :owner

    def initialize(pieces, owner)
      super(pieces)
      @owner = owner
    end

    def swap(other)
      owner.remove(pieces)
      other.owner.remove(other.pieces)

      owner.add(other.pieces)
      other.owner.add(pieces)
    end
  end
end