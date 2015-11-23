module RSpecHelpers
  def delta(units = nil)
    result = 0.00000001
    if units
      Unit.new(result, units)
    else
      result
    end
  end
end
