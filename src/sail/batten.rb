require "math/vector2"

module Sail
  class Batten
    attr_accessor :tack, :clew
    def initialize(length, luff_position, angle)
      @tack = luff_position
      @clew = self.tack + Vector2.from_angle(angle, length)
    end
  end
end
