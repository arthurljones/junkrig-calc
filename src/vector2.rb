class Vector2
  attr_reader :vector

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

  def self.from_angle(rad, mag = 1.0)
    new(Math::cos(rad) * mag, Math::sin(rad) * mag)
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

  def to_s(unit=nil)
    "#{x.round(3)}#{unit} #{y.round(3)}#{unit}"
  end

  def perpendicular_dot(other)
    perpendicular.inner_product(other)
  end

private

  def method_missing(meth, *args, &block)
    assignment = meth =~ /\A[\*\+\-\/]=\Z/
    meth = meth[0] if assignment

    if @vector.respond_to?(meth)
      args.map! { |arg| Vector2 === arg ? arg.vector : arg }
      result = @vector.send(meth, *args.map{ |arg| Vector2 === arg ? arg.vector : arg }, &block)
      if assignment
        @vector = result
        result = self
      elsif Vector === result
        result = Vector2.new(result)
      end
      result
    else
      super
    end
  end

  def respond_to_missing?(meth, include_private = false)
    @vector.respond_to?(meth, include_private)
  end

end