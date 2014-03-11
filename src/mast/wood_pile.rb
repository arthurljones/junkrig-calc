module Mast
  class WoodPile < Stave
    def initialize
      super(0)
      @desired_unscarfed_length = 0
      @desired_length = 0
    end

    def to_s
      "Wood Pile"
    end
  end
end