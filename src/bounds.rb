class Bounds
  attr_accessor :min, :max
  def initialize(minimum, maximum)
    @min = minimum
    @max = maximum
  end

  def self.from_points(points)
    Bounds(Vector2[points.min(&:x), points.min(&:y)], Vector2[points.max(&:x), points.max(&:y)])
  end

  def size
    max - min
  end

  def scale(scale)
    Bounds(min * scale, max * scale)
  end
end