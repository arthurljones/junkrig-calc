class BattenSet
  attr_reader :aft, :center, :fore

  def initialize(aft, center, fore)
    @aft = aft
    @center = center
    @fore = fore
  end

  def to_s
    "#{aft.to_s(true)}#{center.to_s(true)}#{fore}"
  end

end