require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Multiplied
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      options_initialize(
        :section => { },
        :multiplier => { :default => 1 }
      ) do |options|
        @second_moment_of_area = @section.second_moment_of_area * @multiplier
        @extreme_fiber_radius = @section.extreme_fiber_radius
        @area = @section.area * @multiplier
      end

      def neutral_axis_through_centroid
        @section.neutral_axis_through_centroid
      end

      def structure_content(depth = 0, &block)
        "#{@multiplier}\n#{@section.structure_string(depth + 1, &block)}"
      end

      def to_s
        structure_content
      end
    end
  end
end
