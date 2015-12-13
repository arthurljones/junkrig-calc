require "options_initializer"
require "math/vector2"

module Sheet
  class Segment
    include OptionsInitializer

    attr_reader(*%i(
      tension
    ))

    options_initialize(
      length: { units: "in" },
      points: { }
    ) do |options|
      @tension = Unit.new("0 lbf")
      @length_to_force = Unit.new("100 lbf/in")
      #@max_tension_change = Unit.new("10 lbf")
    end

    def apply
      actual_length = points.each_cons(2).sum { |p0, p1| (p1.position - p0.position).magnitude }
      stretch = actual_length - length
      if stretch > 0
        ap stretch
        tension_change = stretch * @length_to_force
        @tension += tension_change
        @tension = [@tension, Unit.new("0 lbf")].max
      else
        @tension = Unit.new("0 lbf")
      end

      points.each_cons(2).each do |p0, p1|
        force = (p1.position - p0.position).normalize * @tension
        p0.apply_force( force)
        p1.apply_force(-force)
      end
    end

  end
end
