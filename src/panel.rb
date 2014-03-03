class Panel
  attr_accessor :head, :foot, :area, :center

  def initialize(foot, head)
    @foot = foot
    @head = head

    area_accum = 0
    center_accum = Vector2.new
    perim = perimeter
    perim << perim.first #Loop around
    perim.each_cons(2) do |p0, p1|
      area_component = p0.perpendicular_dot(p1)
      area_accum += area_component
      center_accum += (p0 + p1) * area_component
    end

    @area = area_accum * 0.5
    @center = center_accum / (@area * 6)
  end

  def perimeter
    [foot.tack, foot.clew, head.clew, head.tack]
  end
end