require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Composite
      include CrossSection
      include OptionsInitializer
      include Multipliable

      options_initialize() do |options|
        @sections = []
        @area  = 0
        @second_moment_of_inertia = 0
        @extreme_fiber_radius = 0
      end

      def add(section)
        @sections << section

        @area = @sections.sum(&:area)
        @second_moment_of_inertia = @sections.sum(&:second_moment_of_inertia)
        #TODO: May not be correct for non-symmetrical sections
        @extreme_fiber_radius = @sections.max(&:extreme_fiber_radius)
      end

      def <<(section)
        add(section)
      end

      def neutral_axis_through_centroid
        false
      end
    end

    module Compositable
      extend ActiveSupport::Concern
      included do
        def add(section)
          result = new Composite()
          result << self
          result
        end

        def <<(section)
          add(section)
        end
      end
    end
  end
end
