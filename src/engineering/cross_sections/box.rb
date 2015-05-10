require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class Box
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      options_initialize(
        :height => { :units => "in" },
        :width => { :units => "in" },
      ) do |options|

        @area = @height * @width
        @second_moment_of_area = @width * @height ** 3
        @extreme_fiber_radius = @height / 2
      end

      def structure_content(depth = 0)
        "#{height}x#{width}"
      end

    end
  end
end
