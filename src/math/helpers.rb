module MathHelpers
  module_function

  def triangle_height(side_a, side_b, base)
    p_2 = (side_a + side_b + base) / 2 #semiperimeter
    area = Math::sqrt(p_2 * (p_2 - side_a) * (p_2 - side_b) * (p_2 - base))
    2 * area / base
  end

  def inches_and_eighths(inches)
    eighth = 0.125
    inches = round(inches / eighth) * eighth
    eighths = (inches % 1) / rounding_precision
    "#{inches.to_i}-#{eighths.to_i}/8\""
  end

end
