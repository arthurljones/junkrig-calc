require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Box
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsetable

      options_initialize(
        :perpendicular_dimension => { :units => "in" },
        :parallel_direction => { :units => "in" },
      ) do |options|

        @area = perpendicular_dimension * parallel_direction
        @second_moment_of_area = @perpendicular_dimension ** 3 * @parallel_direction
        @extreme_fiber_radius = @perpendicular_dimension / 2
      end
    end
  end
end
