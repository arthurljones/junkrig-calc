require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class Semicircle
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsetable

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
