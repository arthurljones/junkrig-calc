require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Defect
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      options_initialize(
        :section => { }
      ) do |options|
        @second_moment_of_area = -@section.second_moment_of_area
        @extreme_fiber_radius = "0 in"
        @area = "0 in^2"
      end

      def neutral_axis_through_centroid
        @section.neutral_axis_through_centroid
      end

      def structure_content(depth = 0, &block)
        "\n#{@section.structure_string(depth + 1, &block)}"
      end
    end
  end
end
