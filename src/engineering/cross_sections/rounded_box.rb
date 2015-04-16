require "engineering/cross_section"
require "options_initializer"

module Engineering
  module CrossSections
    class RoundedBox
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsetable

      attr_reader :inner_diameter, :wall_thickness

      options_initialize(
        :perpendicular_dimension => { :units => "in" },
        :parallel_direction => { :units => "in" },
        :wall_thickness => { :required => false, :units => "in" },
        :corner_radius => { :required => false, :units => "in" },
        :wall_defect_width => { :units => "in", :default => "0 in" },
        :gusset_size => { :units => "in", :default => "0 in" },
        :triangular_gussets => { :default => false },
      ) do |options|

        perpendicular_thickness = wall_thickness || @parallel_dimension / 2
        parallel_thickness = wall_thickness || @perpendicular_dimension / 2

        inner_perpendicular = @perpendicular_dimension - 2 * perpendicular_thickness
        inner_parallel = @parallel_thickness - 2 * parallel_thickness

        square_corner = new Box(:perpendicular_diminison => @corner_radius, :parallel_diminison => @corner_radius)
        square_corner_distance = (@perpendicular_dimension - @corner_radius) / 2
        square_corner = new Offset(square_corner, square_corner_distance)

        radiused_corner = new Semicircle(:outerDiameter => @corner_radius)
        radiused_corner_distance = square_corner_distance + radiused_corner.centroid_from_base
        radiused_corner = new Offset(radiused_corner, radiused_corner_distance)

        square_corner_moment = square_corner.parallel_second_moment_of_area(square_corner_distance)






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

        #The area of the empty n-gon at the middle of the cross section
        empty_area = (inner_radius**2 * sides * sin_alpha) / 2
        #The length of each side of the empty area
        inner_wall_width = inner_diameter * Math.sin(half_alpha)

        ideal_circular_area = Math::PI * outer_radius**2
        @area = ideal_circular_area - empty_area

        #Defects are modeled as a rectangular void that extends from the outer surface halfway through the wall at the
        # furthest distance from the neutral axis. The void's width is adjusted to match the specified defect area ratio.
        defect_area = @defect_to_total_area_ratio * area
        defect_thickness = wall_thickness / 2
        defect_width = defect_area / defect_thickness
        defect_moment = (defect_width * defect_thickness**3) / 12 + defect_area * (outer_radius - defect_thickness / 2)**2

        empty_moment = empty_area * (12 * inner_radius**2 + inner_wall_width**2) / 48.0
        ideal_circular_moment = Math::PI * outer_radius**4 / 4
        @second_moment_of_area = ideal_circular_moment - (empty_moment + defect_moment)
      end

      def square_corner_area
        @corner_radius ** 2
      end

      def square_corner_moment
        local_moment = @corner_radius ** 4 / 12

      end
    end
  end
end
