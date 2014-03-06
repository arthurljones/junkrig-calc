class Transform
  extend MathProxy

  SCALE_UNITS = "in"

  attr_accessor :matrix
  math_proxy :matrix, Matrix

  def self.translation(vector)
    vector = vector.to(SCALE_UNITS).unitless
    new(Matrix.rows([
      [1, 0, vector.x],
      [0, 1, vector.y],
      [0, 0, 1]
    ]))
  end

  def self.scale(amount)
    amount = Vector2.new(amount, amount) if Numeric === amount
    amount = amount.to(SCALE_UNITS).unitless
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
    value = value.to(SCALE_UNITS).unitless
    matrix[2, 0] = value.x
    matrix[2, 1] = value.y
    orig
  end

  def with_translation(value)
    value = value.to(SCALE_UNITS).unitless
    Transform.new(Matrix.columns([matrix.column(0), matrix.column(1), [value.x, value.y, 1]]))
  end

  def *(other)
    if Vector2 === other
      other = other.to(SCALE_UNITS).unitless
      vector = matrix * Vector[other.x, other.y, 1]
      Vector2.new(vector[0].scalar, vector[1].scalar, :units => SCALE_UNITS)
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

end