class BattenPiece

  attr_reader :name, :center, :big_end, :small_end, :big_quarter, :small_quarter, :truncated

  def initialize(name, ends)
    #ignore "thick" param for now
    ends = ends.select{|e| Numeric === e}.sort.reverse
    @name = name
    @big_end = ends.first
    @small_end = ends.last
    @truncated = false
    @center = round_to_eighths((@big_end + @small_end) / 2)
    @big_quarter = round_to_eighths(@big_end * (3/4) + @small_end * (1/4))
    @small_quarter = round_to_eighths(@big_end * (1/4) + @small_end * (3/4))
  end

  def to_s(reverse = false)
    if reverse
      first = :small_end
      last = :big_end
    else
      first = :big_end
      last = :small_end
    end

    "[#{truncation_symbol(first)}#{printed_end(first)}  #{name}  #{printed_end(last)}#{truncation_symbol(last)}]"
  end

  def best_match_for(diameter)
    [big_end_diff(diameter), big_quarter_diff(diameter)].min
  end

  def truncate_for(diameter)
    if big_end_diff(diameter) <= big_quarter_diff(diameter)
      @small_end = small_quarter
      @truncated = :small_end
    else
      @big_end = big_quarter
      @truncated = :big_end
    end
  end

  def ends
    [big_end, small_end]
  end

protected

  def big_end_diff(diameter)
    (big_end - diameter).abs
  end

  def big_quarter_diff(diameter)
    (big_quarter - diameter).abs
  end

  def print_float(num)
    "%.3f" % num
  end

  def round_to_eighths(num)
    (num * 8).round.to_i / 8
  end

  def printed_end(which)
    print_float(send(which))
  end

  def truncation_symbol(which)
    truncated == which ? '|' : '-'
  end

end