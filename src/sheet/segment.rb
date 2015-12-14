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
      @elongation = 0.167 #Elongation to breaking stress
      @tensile_strength = Unit.new("2650 lbf")
      @max_tension_change = Unit.new("1000 lbf")
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

      #max_length = @length * (1 + @elongation * @tension / @tensile_strength)

      puts measured_length: measured_length, length: @length

      if measured_length >= @length
        prev_tension = @tension

        tension_vectors.each do |point, tension_vector|
          purchase = tension_vector.norm
          direction = tension_vector / purchase
          tension_change = -point.prev_force.dot(direction) / purchase
          tension_change = Unit.new("0 lbf") if point.fixed?
          #puts point: point, tension_change: tension_change
          @tension += tension_change
        end

        theoretical_tension = (@tensile_strength * (measured_length - @length)) / (@elongation * @length)

        @tension = [@tension, Unit.new("0 lbf")].max
        @tension = [@tension, prev_tension + @max_tension_change].min
        puts tension: tension, theoretical_tension: theoretical_tension

        #puts tension: tension

        tension_vectors.each do |point, tension_vector|
          #puts point: point, tension_vector: tension_vector, force: tension_vector * @tension
          point.apply_force(tension_vector * @tension)
        end
      else
        @tension = Unit.new("0 lbf")
      end
    end
  end
end
