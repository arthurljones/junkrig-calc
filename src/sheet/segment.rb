require "options_initializer"
require "math/vector2"
require "engineering/pid_controller"
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
      max_tension: { units: "lbf", default: Unit.new("100000 lbf") }, #5
    ) do |options|
      @pid_controller = PIDController.new(p: 0.5, zero: Unit.new("0 lbf"))
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

      #ap "Strain on #{@name}: #{strain}"

      error = Unit.new("0 lbf")

      if strain < 0
        #ap "#{@name} slack"
        error = @tension
      else
        error = -strain * Unit.new("0.05 lbf/in")
      end

      tension_vectors.each do |point, tension_vector|
        next if point.fixed?

        purchase = tension_vector.norm
        direction = tension_vector / purchase
        local_error = point.prev_force.dot(direction) / purchase

        error += local_error
        #puts segment: @name, point: point.name, error: local_error
      end

      correction = @pid_controller.step(error)
      @tension += correction
      #puts error: error, correction: correction, tension: @tension

      #theoretical_tension = (@tensile_strength * (measured_length - @length)) / (@elongation * @length)

      @tension = [[@tension, Unit.new("0 lbf")].max, @max_tension].min

      if @tension > @tensile_strength
        raise RuntimeError.new("Rope tensile strength exceeded (#{@tension} > #{@tensile_strength})")
      end

      tension_vectors.each do |point, tension_vector|
         point.apply_force(tension_vector * @tension)
      end
    end

    def inspect
      to_s
    end

    def to_s
      "#{self.class.name.demodulize} #{@name}: Tension: #{@tension}"
    end
  end
end
