require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require "options_initializer"

module Engineering
  module CrossSections
    class RegularPolygon
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :circumference

      #NOTE/TODO: This assumes NA passes through circumradius and that the extreme fiber is aligned with the circumradius.
      #Formulas: http://mathworld.wolfram.com/RegularPolygon.html

      options_initialize(
        :sides => { },
        :circumradius => { :units => "in", :required => false },
        :side_length => { :units => "in" , :required => false },
      ) do |options|

        raise "This section must have 3 or more sides" unless @sides >= 3
        raise "Either circumradius or side_length is required" unless @circumradius || @side_length
        raise "Only one of circumradius or side_length is allowed" if @circumradius && @side_length

        half_alpha = Math::PI/@sides
        if @circumradius
          @side_length = 2 * @circumradius * Math.sin(half_alpha)
        else
          @circumradius = @side_length / (Math.sin(half_alpha) * 2)
        end

        @area = (@circumradius**2 * sides * Math.sin(half_alpha * 2)) / 2
        @second_moment_of_area = @area * (12 * @circumradius**2 + @side_length**2) / 48.0
        @extreme_fiber_radius = @circumradius
        @circumference = @side_length * @sides
      end
    end
  end
end
