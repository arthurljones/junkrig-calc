require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Composite
      include CrossSection
      include OptionsInitializer
      include Multipliable
      include Compositable

      options_initialize(
        :sections => { :default => [] }
      ) do |options|
        calculate
      end

      def append(section)
        @sections << section
        calculate
      end

      def <<(section)
        append(section)
      end

      def calculate
        @area = @sections.sum(&:area)
        @second_moment_of_area = @sections.sum(&:second_moment_of_area)
        #TODO: May not be correct for non-symmetrical sections
        @extreme_fiber_radius = @sections.collect(&:extreme_fiber_radius).max
      end

      def neutral_axis_through_centroid
        false
      end

      def structure_content(depth = 0, &block)
        "\n#{@sections.map{|section| section.structure_string(depth + 1, &block)}.join("\n")}"
      end
    end
  end
end
