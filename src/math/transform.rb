require "math/math_proxy"

class Transform
  extend MathProxy

  SCALE_UNITS = "in"

  attr_accessor :matrix
  math_proxy :matrix, Matrix

  def self.translation(vector)
    vector = to_unitless(vector)
    new(Matrix.rows([
      [1, 0, vector.x],
      [0, 1, vector.y],
      [0, 0, 1]
    ]))
  end

  def self.scale(amount)
    amount = Vector2.new(amount, amount) if Numeric === amount
    amount = to_unitless(amount)
    new(Matrix.rows([
      [amount.x, 0, 0],
      [0, amount.y, 0],
      [0, 0, 1]
    ]))
  end

  def self.rotation(amount)
    amount = amount.to("radians")
    cosine = Math::cos(amount)
    sine = Math::sin(amount)
    new(Matrix.rows([
      [cosine, sine, 0],
      [-sine, cosine, 0],
      [0, 0, 1]
    ]))
  end

  def initialize(matrix = nil) #If matrix is specified, it will be assumed to be in SCALE_UNITS already
    @matrix = matrix || Matrix.identity(3)
  end

  def translated(vector)
    self * Transform.translation(vector)
  end

  def scaled(amount)
    self * Transform.scale(amount)
  end

  def rotated(degrees)
    self * Transform.rotation(degrees)
  end

  def translation
    Vector2.(matrix.column(3), :units => SCALE_UNITS)
  end

  def scale
    Vector2.new(Vector2.new(matrix.row(0)).magnitude, Vector2.new(matrix.row(1)).magnitude).unitless
  end

  def rotation
    Unit(Math::atan2(matrix[1, 2], matrix[1, 1]), "radians")
  end

  def translation=(value)
    orig = value
    value = to_unitless(value)
    matrix[2, 0] = value.x
    matrix[2, 1] = value.y
    orig
  end

  def with_translation(value)
    value = to_unitless(value)
    Transform.new(Matrix.columns([matrix.column(0), matrix.column(1), [value.x, value.y, 1]]))
  end

  def *(other)
    if Vector2 === other
      other = to_unitless(other)
      vector = matrix * Vector[other.x, other.y, 1]
      Vector2.new(Unit.new(vector[0].scalar, SCALE_UNITS), Unit.new(vector[1].scalar, SCALE_UNITS))
    else
      super
    end
  end

  def to_xml
    matrix.row_vectors.map{ |row| row.map { |el| el.scalar.round(5).to_f }}.to_json
  end

  def self.from_xml(str)
    new(Matrix.rows(JSON.parse(str).map{|row| row.map{|el| el.to_f}}))
  end

private

  def to_unitless(vec)
    Transform.to_unitless(vec)
  end

  def self.to_unitless(vec)
    vec.unitless? ? vec : vec.to(SCALE_UNITS).unitless
  end

end
