class Batten
  attr_accessor :tack, :clew
  def initialize(length, luff_height, angle)
    @tack = Vector2.new(0, luff_height)
    @clew = self.tack + Vector2.from_angle(angle, length)
  end
end
