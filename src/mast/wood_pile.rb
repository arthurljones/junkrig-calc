require_relative 'stave'
module Mast
  class WoodPile < Stave
    def initialize(initial)
      super(initial)
      @desired_unscarfed_length = 0
      @desired_length = 0
    end

    def to_s
      "Wood Pile"
    end
  end
end