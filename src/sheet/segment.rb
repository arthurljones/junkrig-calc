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
      max_tension_change: { units: "lbf", default: Unit.new("100 lbf") }, #5
    ) do |options|
      @prev_error = Unit.new("0 lbf")
      @error_derivator = Unit.new("0 lbf")
      @error_derivator_weight = 1/5
      @error_integrator = Unit.new("0 lbf")

      @proportional_coefficient = 0.5
      @integral_coefficient = 0
      @derivative_coefficient = 0
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

      total_error = Unit.new("0 lbf")

      if strain < 0
        ap "#{@name} slack"
        total_error = @tension
      end

      tension_vectors.each do |point, tension_vector|
        next if point.fixed?

        purchase = tension_vector.norm
        direction = tension_vector / purchase
        error = point.prev_force.dot(direction) / purchase

        total_error += error
        puts segment: @name, point: point.name, error: error
      end

      error_slope = total_error - @prev_error
      @prev_error = total_error
      @error_derivator = @error_derivator * (1 - @error_derivator_weight) + error_slope * @error_derivator_weight
      @error_integrator += total_error

      proportional = total_error * @proportional_coefficient
      integral = @error_integrator * @integral_coefficient
      derivative = @error_derivator * @derivative_coefficient

      correction = -(proportional + integral + derivative)
      puts error: total_error, p: proportional, i: integral, d:derivative, c: correction
      @tension += correction

      #theoretical_tension = (@tensile_strength * (measured_length - @length)) / (@elongation * @length)

      tension_vectors.each do |point, tension_vector|
         point.apply_force(tension_vector * @tension)
      end

      @tension = [@tension, Unit.new("0 lbf")].max
    end

    def inspect
      to_s
    end

    def to_s
      "#{self.class.name.demodulize} #{@name}: Tension: #{@tension}"
    end
  end
end
