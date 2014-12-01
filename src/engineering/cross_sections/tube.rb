require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Tube
      include CrossSection
      include OptionsInitializer
      attr_reader :outer_radius, :wall_thickness

      options_initialize(
        :outer_diameter => { :required => :true, :units => "in", :write => false },
        :wall_thickness => { :required => :true, :units => "in" },
      ) do |options|
        @outer_radius = options[:outer_diameter] / 2.0
        raise "outer_diameter must be more than 0" unless outer_diameter > "0 in"
        raise "wall_thickness must be more than 0" unless wall_thickness > "0 in"
      end

      def outer_diameter
        outer_radius * 2
      end

      def inner_radius
        outer_radius - wall_thickness
      end

      def inner_diameter
        inner_radius * 2
      end

      def area
        Math::PI * (outer_radius**2 - inner_radius**2)
      end

      def second_moment_of_area
        Math::PI/4 * (outer_radius**4 - inner_radius**4)
      end

      def extreme_fiber_radius
        outer_radius
      end
    end
  end
end
