module RSpecHelpers
  def delta(units)
    result = 0.00000001
    if units
      Unit(result, units)
    else
      result
    end
  end
end
