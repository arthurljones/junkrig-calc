require "options_initializer"
require "math/vector2"
require 'securerandom'

module Sheet
  class Segment
    include OptionsInitializer

    options_initialize(
      length: { units: "in" },
      points: { },
      name: { class: String, default: -> { SecureRandom.uuid } },
      tension: { units: "lbf", default: Unit.new("0 lbf") },
      elongation: { default: 0.167 }, #Elongation to breaking stress
      tensile_strength: { units: "lbf", default: Unit.new("2650 lbf") },
      max_tension_change: { units: "lbf", default: Unit.new("10 lbf") },
    ) do |options|
      @prev_tension = @tension
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

      ap "Strain on #{@name}: #{strain}"

      if strain < 0
        ap "#{@name} slack"
        @tension -= (strain / max_length).abs * Unit.new("10 lbf")
      end

      @prev_tension = @tension

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

      puts desired_tension: @tension
      @tension += strain * Unit.new("0.2 lbf/in")
      @tension = [@tension, @prev_tension + @max_tension_change].min

      tension_vectors.each do |point, tension_vector|
         point.apply_force(tension_vector * @tension)
      end

      @tension = [@tension, Unit.new("0 lbf")].max
    end

    def inspect
      to_s
    end

    def to_s
      "#{self.class.name.demodulize} #{@name}: Tension: #{@tension}, Delta: #{@tension - @prev_tension}"
    end
  end
end
