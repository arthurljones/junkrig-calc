require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Tube
      include CrossSection
      include OptionsInitializer

      attr_reader *%i(
        outer_radius
        inner_diameter
        inner_radius
        area
        second_moment_of_area
        extreme_fiber_radius
      )

      options_initialize(
        :outer_diameter => { :required => :true, :units => "in" },
        :wall_thickness => { :required => :true, :units => "in" },
      ) do |options|
        raise "outer_diameter must be more than 0" unless @outer_diameter > "0 in"
        raise "wall_thickness must be more than 0" unless @wall_thickness > "0 in"

        @outer_radius = @outer_diameter / 2.0
        @inner_radius = @outer_radius - @wall_thickness
        @inner_diameter = @inner_radius * 2

        @area = Math::PI * (outer_radius**2 - inner_radius**2)
        @second_moment_of_area = Math::PI/4 * (outer_radius**4 - inner_radius**4)
        @extreme_fiber_radius = @outer_radius
      end
    end
  end
end
