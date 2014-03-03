class Vector2
  extend MathProxy

  attr_reader :vector
  math_proxy :vector, Vector

  def initialize(*args)
    if args.size == 1
      args = args.first.first(2)
    end

    if args.size == 0
      args = [0, 0]
    elsif args.size != 2
      raise "Args must be two numbers, or an array or vector with two values"
    end

    @vector = Vector.elements(args)
  end

  def self.from_angle(angle, mag = 1.0, degrees = false)
    angle *= Math::PI / 180 if degrees
    new(Math::cos(angle) * mag, Math::sin(angle) * mag)
  end

  def x
    @vector[0]
  end

  def x=(val)
    @vector = Vector[val, y]
  end

  def y
    @vector[1]
  end

  def y=(val)
    @vector = Vector[x, val]
  end

  def perpendicular
    Vector2.new(-y, x)
  end

  def -@
    Vector2.new(-x, -y)
  end

  def componentwise_scale(other)
    Vector2.new(x * other.x, y * other.y)
  end

  def to_s(unit = nil)
    "#{x.round(3)}#{unit} #{y.round(3)}#{unit}"
  end

  def perpendicular_dot(other)
    perpendicular.inner_product(other)
  end

end