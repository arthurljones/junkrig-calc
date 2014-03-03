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

  def translate(vector)
    self * Transform.translation(vector)
  end

  def scale(amount)
    self  * Transform.scale(amount)
  end

  def rotate(degrees)
    self * Transform.rotation(degrees)
  end

  def *(other)
    if Vector2 === other
      vector = matrix * Vector[other.x, other.y, 1]
      Vector2.new(vector)
    else
      super
    end
  end

end