require_relative "../cross_section"
require_relative "../options_initializer"

module CrossSections
  class Birdsmouth
    include CrossSection
    include OptionsInitializer

    attr_reader *%i(
      sides
      stave_thickness
      stave_width
      outer_diameter
      inner_diameter
      extreme_fiber_radius
      wall_thickness
      area
      second_moment_of_area
      defect_to_total_area_ratio
    )

    options_initialize(
      :stave_thickness => { :required => :true, :units => "in" },
      :outer_diameter => { :units => "in" },
      :stave_width => { :units => "in" },
      :sides => { :required => true, :default => 8 },
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
  end
end
