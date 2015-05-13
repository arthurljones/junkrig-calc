require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"

require_relative "tube"
require_relative "box"
require_relative "defect"
require_relative "regular_polygon"

require "options_initializer"

module Engineering
  module CrossSections
    class Birdsmouth
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :inner_diameter, :wall_thickness, :circumference, :section

      options_initialize(
        :stave_thickness => { :units => "in" },
        :outer_diameter => { :required => false, :units => "in" },
        :stave_width => { :required => false, :units => "in" },
        :sides => { :default => 8 },
        :defect_to_total_area_ratio => { :default => 0 }
      ) do |options|

        raise "Sides must be at least 5" if @sides < 5
        raise "Exactly one of stave_width or outer_diameter must be specified" unless @stave_width.present? ^ @outer_diameter.present?

        #alpha is the angle each stave's inner wall subtends, plus often-used convenience values
        alpha = Math::PI * 2 / sides
        half_alpha = alpha / 2
        sin_alpha = Math.sin(alpha)

        #Stave width and outer diameter can each be calculated from the other
        if @stave_width.present?
          @outer_diameter = (stave_width - stave_thickness * sin_alpha) / Math.tan(half_alpha) + 2 * stave_thickness
        else
          @stave_width = (target_diameter - 2 * stave_thickness) * Math.tan(half_alpha) + stave_thickness * sin_alpha
        end

        @inner_diameter = (stave_width - stave_thickness * sin_alpha) / Math.sin(half_alpha)

        @wall_thickness = (@outer_diameter - @inner_diameter) / 2

        outer_radius = @outer_diameter / 2
        inner_radius = @inner_diameter / 2

        @extreme_fiber_radius = outer_radius

        filled_circle = Tube.new(outer_diameter: outer_diameter)
        empty_area = RegularPolygon.new(sides: @sides, circumradius: inner_radius)

        @section = filled_circle - empty_area

        #Defects are modeled as a rectangular void that extends from the outer surface halfway through the wall at the
        #furthest distance from the neutral axis. The void's width is adjusted to match the specified defect area ratio.
        defect_thickness = wall_thickness / 2
        defect = Box.new(height: defect_thickness, width: @defect_to_total_area_ratio * @section.area / defect_thickness)
        defect = Defect.new(section: defect.offset(outer_radius - defect_thickness / 2)) #TODO: This puts the corners of the defect outside the wall
        @section = @section + defect

        @area = @section.area
        @second_moment_of_area = @section.second_moment_of_area
        @extreme_fiber_radius = @section.extreme_fiber_radius
        @circumference = filled_circle.circumference
      end

      def structure_content(depth = 0)
        "#{outer_diameter} OD, #{sides} staves: #{stave_width}x#{stave_thickness}"
      end
    end
  end
end
