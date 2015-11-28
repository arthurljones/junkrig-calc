require "options_initializer"
require "engineering/variable_spar"
require "engineering/cross_sections/tube"
require_relative "boat"
require_relative "sail/sail"

class Rig
  include OptionsInitializer

  #MASTHEAD_TO_PARTNERS_MINIMUM = 0.4
  #MASTHEAD_TO_FOOT_MINIMUM = 0.5

  attr_reader(*%i(
    partners_above_center_of_mass
    minimum_safe_roll_angle
    center_of_area_above_partners
    center_of_area_above_center_of_mass
    max_force_on_sail_center_of_area

    max_moment_at_partners
    yield_moment_at_partners
    partners_safety_factor

    max_moment_at_sleeve
    yield_moment_at_sleeve
    sleeve_safety_factor

    sail_area_to_displacement
    s_number
    mast_height_above_sling_point
    mast_tip_to_batten_length
    max_halyard_lead_angle
    partners_to_sheet_anchor
    lower_mast
    total_mast_mass
  ))

  options_initialize(
    tack_above_partners: { units: "in" },
    partners_above_waterline: { units: "in" },
    partners_above_lower_foot: { units: "in" },
    partners_above_upper_foot: { units: "in" },
    partners_to_sheet_anchor_x: { units: "in"},
    partners_to_sheet_anchor_y: { units: "in"},
    upper_mast: { class: Engineering::VariableSpar },
    sail: { class: Sail::Sail },
    boat: { class: Boat },
  ) do |options|
    @lower_mast = setup_lower_mast(options[:lower_mast].merge(foot_to_partners: @partners_above_lower_foot), @upper_mast)
    @total_mast_mass = lower_mast.mass #upper_mast.mass

    @partners_above_center_of_mass = @partners_above_waterline + @boat.waterline_above_center_of_mass

    clew_above_partners = @tack_above_partners + @sail.clew_rise
    clew_above_waterline = clew_above_partners + @partners_above_waterline
    @minimum_safe_roll_angle = Unit.new(Math.atan2(clew_above_waterline, @sail.clew_to_mast_center), "rad")
    @center_of_area_above_partners = @tack_above_partners + @sail.center.y
    @center_of_area_above_center_of_mass = @partners_above_center_of_mass + @center_of_area_above_partners
    @max_force_on_sail_center_of_area = @boat.estimated_max_righting_moment / @center_of_area_above_center_of_mass

    @max_moment_at_partners = @max_force_on_sail_center_of_area * @center_of_area_above_partners
    @yield_moment_at_partners = @lower_mast.cross_section(@partners_above_lower_foot).elastic_section_modulus * @lower_mast.material.yield_strength
    @partners_safety_factor = @yield_moment_at_partners / @max_moment_at_partners

    sleeve_overlap = Unit.new(options[:lower_mast][:overlap])
    @max_moment_at_sleeve = @max_force_on_sail_center_of_area * (@center_of_area_above_partners - sleeve_overlap)
    @yield_moment_at_sleeve = @upper_mast.cross_section(sleeve_overlap).elastic_section_modulus * @upper_mast.material.yield_strength
    @sleeve_safety_factor = @yield_moment_at_sleeve / @max_moment_at_sleeve

    below_partners = @partners_above_lower_foot
    lower_mast_ft = below_partners.to("ft").scalar.to_i
    safeties = (0..lower_mast_ft).each_with_object({}) do |feet, result|
      position = Unit.new(feet, "ft")

      parameter = position / below_partners
      max_moment = [@max_moment_at_partners * parameter, Unit.new("1 ft*lbf")].max

      yield_moment = @lower_mast.cross_section(position).elastic_section_modulus * @lower_mast.material.yield_strength

      result[position] = (yield_moment / max_moment).to(Unit.new(1))
    end
    ap safeties

    upper_mast_feet = upper_mast.length.to("ft").scalar.to_i
    safeties = (0..upper_mast_feet).each_with_object({}) do |feet, result|
      position = Unit.new(feet, "ft")

      sail_start = @tack_above_partners
      parameter = 1 - [position - sail_start, Unit.new("0 in")].max / (@upper_mast.length - sail_start)
      max_moment = @max_force_on_sail_center_of_area * parameter * (@upper_mast.length - position) / 2
      max_moment = [max_moment, Unit.new("200 ft*lbf")].max

      yield_moment = @upper_mast.cross_section(position).elastic_section_modulus * @upper_mast.material.yield_strength

      result[position] = (yield_moment / max_moment).to(Unit.new(1))
    end
    ap safeties

    ap @lower_mast.spans.values.collect(&:volume)

    @sail_area_to_displacement = (@sail.area / (@boat.saltwater_displaced**(2/3))).to(Unit.new(1))
    dlr = @boat.displacement_to_length
    sad = @sail_area_to_displacement
    @s_number = 3.972 * 10 ** (-dlr/526 + 0.691 * (Math::log10(sad)-1) ** 0.8)

    upper_mast_foot_to_sling_point = @partners_above_upper_foot + @tack_above_partners + @sail.sling_point.y
    @mast_height_above_sling_point = @upper_mast.length - upper_mast_foot_to_sling_point
    @mast_tip_to_batten_length = @mast_height_above_sling_point / @sail.batten_length
    upper_masthead_radius = @upper_mast.cross_sections.values.last.extreme_fiber_radius
    halyard_horizontal_distance = @sail.sling_point_to_mast_center - upper_masthead_radius
    @max_halyard_lead_angle = Unit.new(Math.atan2(halyard_horizontal_distance, @mast_height_above_sling_point), "rad")

    @partners_to_sheet_anchor = Vector2.new(@partners_to_sheet_anchor_x, @partners_to_sheet_anchor_y)
    partners_to_clew = Vector2.new(-@sail.clew_to_mast_center, clew_above_partners)
    clew_to_sheet_anchor = partners_to_clew - partners_to_sheet_anchor
    @clew_distance_to_sheet_anchor = clew_to_sheet_anchor.magnitude
    @clew_angle_to_sheet_anchor = clew_to_sheet_anchor.angle

    puts min_sheet_distance_buffer: @clew_distance_to_sheet_anchor - @sail.inner_sheet_distance
    puts clew_angle_to_sheet_anchor: @clew_angle_to_sheet_anchor.to("deg")
  end

  def setup_lower_mast(options, upper_mast)
    def get_inner_section(outer_section, scale)
      outer_diameter = outer_section.inner_diameter * scale
      Engineering::CrossSection.create(
        type: "Tube",
        outer_diameter: outer_diameter,
        wall_thickness: [outer_diameter / 2 - Unit.new("2 in"), Unit.new("2 in")].max
      )
    end

    partners_pos    = Unit.new(options[:foot_to_partners])
    partners_length = Unit.new(options[:partners_length])
    overlap         = Unit.new(options[:overlap])

    base_section = upper_mast.cross_section(Unit.new("0 in"))
    foot      = get_inner_section(base_section, options[:foot_ratio])
    partners  = get_inner_section(base_section, 1.0)
    head      = get_inner_section(upper_mast.cross_section(Unit.new(options[:overlap])), 1.0)

    Engineering::VariableSpar.new(
      material: options[:material],
      section_type: upper_mast.section_type,
      cross_sections: {
        Unit.new("0 in")                => foot,
        partners_pos - partners_length  => partners,
        partners_pos                    => partners,
        partners_pos + overlap          => head,
      }
    )
  end

end
