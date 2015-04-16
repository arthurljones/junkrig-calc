require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Multiplied
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsetable

      options_initialize(
        :section => { },
        :multiplier => { :default => 1 }
      ) do |options|
        if @multiplier % 1 > 0
          puts "Warning: Non-integer multiplier for transformed cross section. This probably won't work correctly"
        end

        @second_moment_of_area = @section.second_moment_of_area * @multiplier
        @extreme_fiber_radius = @section.extreme_fiber_radius
        @area = @section.area * @multiplier
      end

      def neutral_axis_through_centroid
        @section.neutral_axis_through_centroid
      end
    end

    module Multipliable
      extend ActiveSupport::Concern
      included do
        def *(amount)
          new Multiplied(self, amount)
        end
      end
    end
  end
end
