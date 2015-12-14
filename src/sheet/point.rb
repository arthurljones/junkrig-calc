require "math/vector2"

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
      ))

      attr_reader(*%i(
        force
        prev_force
      ))

      def initialize
        @force ||= Vector2.new("0 lbf", "0 lbf")
        @prev_force ||= Vector2.new("0 lbf", "0 lbf")
        @position ||= Vector2.new("0 in", "0 in")
        @prev_movement ||= Vector2.new("0 in", "0 in")
        @force_to_position ||= Unit.new("0.1 in/lbf")

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
        movement = @force * @force_to_position
        distance = movement.magnitude

        #Dampen force and movement if we're switching directions to reduce ringing
        if movement.dot(@prev_movement) < 0
          movement /= 2
          @force /= 2
        end

        @prev_movement = movement
        @position += movement
        @prev_force = @force
        @force = Vector2.new("0 lbf", "0 lbf")

        distance > Unit.new("0.001 in")
      end
    end
  end
end
