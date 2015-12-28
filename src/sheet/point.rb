require "math/vector2"
require 'securerandom'

#Line constraint - total length of line through points/anchors
#Move points proportional to summed force vector
#Increase tension proportional to line constraint
#Eventually add line stretch as a function of tension and line composition

module Sheet
  module Point
    extend ActiveSupport::Concern
    included do
      attr_accessor(*%i(
        position
        force_to_position
        name
      ))

      attr_reader(*%i(
        force
        prev_force
      ))

      def initialize
        @name ||= SecureRandom.uuid
        @force ||= Vector2.new("0 lbf", "0 lbf")
        @prev_force ||= Vector2.new("0 lbf", "0 lbf")
        @position ||= Vector2.new("0 in", "0 in")
        @prev_position ||= @position
        super
      end

      def apply_force(force)
        @force += force
      end

      def fixed?
        false
      end

      #Returns true if point moved by more than a small threshold, or false otherwise
      def resolve
        force_mag = force.norm
        #puts force_mag: force_mag
        if force_mag < Unit.new("0.1 lbf")
          return false
        end

        prev_prev_position = @prev_position
        @prev_position = @position
        prev_movement = @prev_position - prev_prev_position
        movement = (@force / force_mag) * Unit.new("0.05 in")

        #Dampen movement if we're switching directions to reduce ringing
        if movement.dot(prev_movement) < 0
          #puts "#{name} ringing"
          movement /= 2
        end

        @position += movement
        @prev_force = @force
        @force = Vector2.new("0 lbf", "0 lbf")

        return true
      end

      def inspect
        to_s
      end

      def to_s
        "#{self.class.name.demodulize} #{@name}: Position: #{position}, Force: #{prev_force}, Delta: #{@position - @prev_position}"
      end
    end
  end
end
