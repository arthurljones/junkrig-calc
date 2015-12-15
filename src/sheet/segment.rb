require "options_initializer"
require "math/vector2"
require 'securerandom'

module Sheet
  class Segment
    include OptionsInitializer

    attr_reader(*%i(
      tension
    ))

    options_initialize(
      length: { units: "in" },
      points: { },
      name: { class: String, default: -> { SecureRandom.uuid } }
    ) do |options|
      @tension = Unit.new("0 lbf")
      @elongation = 0.167 #Elongation to breaking stress
      @tensile_strength = Unit.new("2650 lbf")
      @max_tension_change = Unit.new("10 lbf")
    end

    def apply
      measured_length = 0
      tension_vectors = Hash.new { |hash, key| hash[key] = Vector2.new(0, 0) }
      points.each_cons(2).each do |p0, p1|
        delta = p1.position - p0.position
        dist = delta.magnitude
        measured_length += dist
        tension_vectors[p0] += delta / dist
        tension_vectors[p1] += delta / -dist
      end

      max_length = @length * (1 + @elongation * @tension / @tensile_strength)

      strain = measured_length - max_length

      if strain >= 0
        prev_tension = @tension

        tension_vectors.each do |point, tension_vector|
          purchase = tension_vector.norm
          direction = tension_vector / purchase
          tension_change = -point.prev_force.dot(direction) / purchase
          if point.fixed?
            tension_change = Unit.new("0 lbf")
          else
            puts segment: @name, point: point.name, tension_change: tension_change
          end
          @tension += tension_change
        end

        #theoretical_tension = (@tensile_strength * (measured_length - @length)) / (@elongation * @length)

        @tension += strain * Unit.new("0.2 lbf/in")
        @tension = [@tension, prev_tension + @max_tension_change].min

        tension_vectors.each do |point, tension_vector|
           point.apply_force(tension_vector * @tension)
        end
      else
        @tension = Unit.new("0 lbf") #-= Unit.new("1 lbf") #
      end

      @tension = [@tension, Unit.new("0 lbf")].max
    end
  end
end
