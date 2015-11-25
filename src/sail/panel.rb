require "math/vector2"

module Sail
  class Panel
    attr_accessor :head, :foot, :tack, :clew, :throat, :peak, :area, :center, :leech_length, :perimeter

    def initialize(foot, head, options = {})
      @foot = foot
      @head = head

      def interpolate_to_x(p0, p1, x)
        p0.interpolate(p1, (x - p0.x) / (p1.x - p0.x))
      end

      if options[:start_x]
        @tack = interpolate_to_x(foot.tack, foot.clew, options[:start_x])
        @throat = interpolate_to_x(head.tack, head.clew, options[:start_x])
      else
        @tack = foot.tack
        @throat = head.tack
      end

      if options[:end_x]
        @clew = interpolate_to_x(foot.tack, foot.clew, options[:end_x])
        @peak = interpolate_to_x(head.tack, head.clew, options[:end_x])
      else
        @clew = foot.clew
        @peak = head.clew
      end

      @perimeter = [@tack, @clew, @peak, @throat] #Clockwise from tack

      area_accum = 0
      center_accum = Vector2.new("0 in", "0 in")
      perim = @perimeter
      perim << perim.first #Loop around
      perim.each_cons(2) do |p0, p1|
        area_component = p0.perpendicular_dot(p1)
        area_accum += area_component
        center_accum += (p0 + p1) * area_component
      end

      @area = area_accum * 0.5
      @center = center_accum / (@area * 6)

      @leech_length = (peak - clew).magnitude
    end
  end
end
