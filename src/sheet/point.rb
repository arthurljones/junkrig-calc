require "math/vector2"

#Line constraint - total length of line through points/anchors
#Move points proportional to summed force vector
#Increase tension proportional to line constraint
#Eventually add line stretch as a function of tension and line composition

#Force in fixed direction vs force toward point

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
      ))

      def initialize
        @force ||= Vector2.new("0 lbf", "0 lbf")
        @position ||= Vector2.new("0 in", "0 in")
        @force_to_position ||= Unit.new("0.1 in/lbf")

        super
      end

      def apply_force(force)
        @force += force
      end

      def resolve
        movement = @force * @force_to_position
        initial_distance = movement.magnitude
        distance = [Unit.new("1 in"), initial_distance].min
        if distance.scalar > 0
          movement = movement * (distance / initial_distance)
        end

        @position += movement
        @force = Vector2.new("0 lbf", "0 lbf")
      end
    end
  end
end
