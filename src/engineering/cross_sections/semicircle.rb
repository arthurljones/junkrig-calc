require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Semicircle
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :centroid_from_base

      options_initialize(
        :radius => { :units => "in" },
      ) do |options|

        @area = Math::PI * @radius ** 2 / 2
        @second_moment_of_area = (Math::PI/8 - 8/(9*Math::PI)) * @radius ** 4
        @centroid_from_base = 4 * @radius / (3 * Math::PI)
        @extreme_fiber_radius = @radius - @centroid_from_base
      end
    end
  end
end
