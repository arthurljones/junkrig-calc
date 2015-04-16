require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Tube
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :outer_radius, :inner_diameter, :inner_radius

      options_initialize(
        :outer_diameter => { :required => :true, :units => "in" },
        :wall_thickness => { :units => "in" },
      ) do |options|
        raise "outer_diameter must be more than 0" unless @outer_diameter > "0 in"

        @outer_radius = @outer_diameter / 2.0

        @wall_thickness ||= @outer_radius

        @inner_radius = @outer_radius - @wall_thickness
        @inner_diameter = @inner_radius * 2

        @area = Math::PI * (outer_radius**2 - inner_radius**2)
        @second_moment_of_area = Math::PI/4 * (outer_radius**4 - inner_radius**4)
        @extreme_fiber_radius = @outer_radius
      end
    end
  end
end
