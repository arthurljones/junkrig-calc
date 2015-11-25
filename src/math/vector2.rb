require "math/math_proxy"

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

    args = args.map do |arg|
      case arg
      when Unit
        arg
      else
        Unit.new(arg)
      end
    end

    @vector = Vector.elements(args)
  end

  def self.from_angle(angle, mag = Unit.new(1), *args)
    angle = angle.to("rad")
    new(Math::cos(angle) * mag, Math::sin(angle) * mag, *args)
  end

  def self.from_complex(complex)
    if Unit === complex
      units = complex.units
      complex = complex.scalar
      new(Unit.new(complex.real, units), Unit.new(complex.imaginary, units))
    else
      new(complex.real, complex.imaginary)
    end
  end

  def self.unitless(*args)
    Vector2.new(*args).unitless
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

  def to_s(units = nil)
    units ||= x.units unless x.units.empty?
    [x, y].map {|val| "#{val.to(units).scalar.to_f.round(3)}#{units}"}.join(" ")
  end

  def to_complex
    Complex(x, y)
  end

  def perpendicular_dot(other)
    perpendicular.inner_product(other)
  end

  def unitless?
    return x.kind == :unitless && y.kind == :unitless
  end

  def to(unit)
    Vector2.new(x.to(unit), y.to(unit))
  end

  def unitless
    Vector2.new(x.scalar, y.scalar)
  end

  def angle
    Unit.new(Math::atan2(y, x), "rad")
  end

  def rotated_by(radians)
    radians = radians.to("radians").scalar if radians.respond_to?(:to)
    complex = to_complex * Math::E ** Complex(0, radians)
    self.class.from_complex(complex)
  end

  def interpolate(other, parameter)
    self + (other - self) * parameter
  end

end
