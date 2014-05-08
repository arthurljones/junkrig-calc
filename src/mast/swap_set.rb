module Mast
  class SwapSet < PieceSet
    attr_accessor :owner

    def initialize(pieces, owner)
      super(pieces)
      @owner = owner
    end

    def swap(other)
      owner >> pieces
      other.owner >> other.pieces

      owner << other.pieces
      other.owner << pieces
    end
  end
end