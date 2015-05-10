require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require "options_initializer"

module Engineering
  module CrossSections
    class Offset
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable

      options_initialize(
        :section => { },
        :offset => { :units => "in" }
      ) do |options|
        raise "Cannot offset objects without NA through centroid" unless @section.neutral_axis_through_centroid
        raise "Offset must be non-negative" if offset < 0

        @second_moment_of_area = @section.second_moment_of_area + @section.area * @offset ** 2
        @extreme_fiber_radius = @section.extreme_fiber_radius + @offset
        @area = @section.area
      end

      def neutral_axis_through_centroid
        false
      end

      def structure_content(depth = 0, &block)
        "#{@offset}\n#{@section.structure_string(depth + 1, &block)}"
      end
    end
  end
end
