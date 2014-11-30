require_relative "../cross_section"

module CrossSections
  class Birdsmouth
    include CrossSection

    options_initialize(
      :stave_thickness => { :required => :true, :units => "in" },
      :outside_diameter => { :units => "in" },
      :stave_width => { :units => "in" },
      :sides => { :default => 8 },
    ) do |options|
      raise "Exactly one of stave_width or outside_diameter must be specified" unless @stave_width.present? ^ @outside_diameter.present?
    end

    def stave_angle
      Math::PI * 2 / sides
    end

    def stave_width
      @stave_width ||
        (target_diameter - 2 * stave_thickness) * Math.tan(stave_angle / 2) + stave_thickness * Math.sin(stave_angle)
    end

    def outside_diameter
      @outside_diameter ||
        (stave_width - stave_thickness * Math.sin(stave_angle)) / Math.tan(stave_angle / 2) + 2 * stave_thickness)
    end

    def inside_diameter
      (stave_width - Math.sin(stave_angle)) / Math.sin(stave_angle / 2)
    end

    def area

    end

    private

    def outside_radius
      outside_diameter / 2

    def inside_radius
      inside_diameter / 2
    end

    def empty_area
      (inside_radius**2 * sides * Math.sin(stave_angle)) / 2
    end

  end
end
