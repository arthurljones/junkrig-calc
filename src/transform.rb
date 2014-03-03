class Transform
  extend MathProxy

  attr_accessor :matrix
  math_proxy :matrix, Matrix

  def self.translation(vector)
    new(Matrix.rows([
      [1, 0, vector.x],
      [0, 1, vector.y],
      [0, 0, 1]
    ]))
  end

  def self.scale(amount)
    amount = Vector2.new(amount, amount) if Numeric === amount
    new(Matrix.rows([
      [amount.x, 0, 0],
      [0, amount.y, 0],
      [0, 0, 1]
    ]))
  end

  def self.rotation(degrees)
    rad = * Math::PI * degrees / 180
    cosine = Math::cos(rad)
    sine = Math::sin(rad)
    new(Matrix.rows([
      [cosine, sine, 0],
      [-sine, cosine, 0],
      [0, 0, 1]
    ]))
  end

  def initialize(matrix = nil)
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
    Vector2.new(matrix.column(3))
  end

  def scale
    Vector2.new(Vector2.new(matrix.row(0)).magnitude, Vector2.new(matrix.row(1)).magnitude)
  end

  def rotation
    Math::atan2(matrix[1, 2], matrix[1, 1])
  end

  def translation=(value)
    matrix[2, 0] = value.x
    matrix[2, 1] = value.y
    value
  end

  def with_translation(value)
    Transform.new(Matrix.columns([matrix.column(0), matrix.column(1), [value.x, value.y, 1]]))
  end

  def *(other)
    if Vector2 === other
      vector = matrix * Vector[other.x, other.y, 1]
      Vector2.new(vector)
    else
      super
    end
  end

  def to_xml
    matrix.row_vectors.to_json
  end

  def self.from_xml(str)
    new(Matrix.rows(JSON.parse(str)))
  end

end