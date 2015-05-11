class Bounds
  attr_accessor :min, :max
  def initialize(minimum, maximum)
    @min = minimum
    @max = maximum
  end

  def self.from_points(points)
    x_min, x_max = points.collect(&:x).minmax
    y_min, y_max = points.collect(&:y).minmax
    new(Vector2.new(x_min, y_min), Vector2.new(x_max, y_max))
  end

  def size
    max - min
  end

  def scale(scale)
    Bounds.new(min * scale, max * scale)
  end
end