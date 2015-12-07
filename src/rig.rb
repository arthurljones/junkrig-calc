require "options_initializer"
require "engineering/variable_spar"
require "engineering/composite_spar"
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
    mast
  ))

  options_initialize(
    tack_above_partners: { units: "in" },
    partners_above_waterline: { units: "in" },
    partners_above_lower_foot: { units: "in" },
    partners_above_upper_foot: { units: "in" },
    partners_to_sheet_anchor_x: { units: "in"},
    partners_to_sheet_anchor_y: { units: "in"},
    mast: { write: false },
    sail: { class: Sail::Sail },
    boat: { class: Boat },
  ) do |options|
    @mast = setup_mast(options[:mast])
    @partners_above_center_of_mass = @partners_above_waterline + @boat.waterline_above_center_of_mass

    clew_above_partners = @tack_above_partners + @sail.clew_rise
    clew_above_waterline = clew_above_partners + @partners_above_waterline
    @minimum_safe_roll_angle = Unit.new(Math.atan2(clew_above_waterline, @sail.clew_to_mast_center), "rad")
    @center_of_area_above_partners = @tack_above_partners + @sail.center.y
    @center_of_area_above_center_of_mass = @partners_above_center_of_mass + @center_of_area_above_partners
    @max_force_on_sail_center_of_area = @boat.estimated_max_righting_moment / @center_of_area_above_center_of_mass

    @max_moment_at_partners = @max_force_on_sail_center_of_area * @center_of_area_above_partners
    @yield_moment_at_partners = @mast.yield_moment(Unit.new("0 in")).values.first
    @partners_safety_factor = @yield_moment_at_partners / @max_moment_at_partners

    @sail_area_to_displacement = (@sail.area / (@boat.saltwater_displaced**(2/3))).to(Unit.new(1))
    dlr = @boat.displacement_to_length
    sad = @sail_area_to_displacement
    @s_number = 3.972 * 10 ** (-dlr/526 + 0.691 * (Math::log10(sad)-1) ** 0.8)

    @mast_height_above_sling_point = @mast.head - (@sail.sling_point.y + @tack_above_partners)
    @mast_tip_to_batten_length = @mast_height_above_sling_point / @sail.batten_length
    masthead_radius = @mast.cross_sections(@mast.head).values.first.extreme_fiber_radius
    halyard_horizontal_distance = @sail.sling_point_to_mast_center - masthead_radius
    @max_halyard_lead_angle = Unit.new(Math.atan2(halyard_horizontal_distance, @mast_height_above_sling_point), "rad")

    @partners_to_sheet_anchor = Vector2.new(@partners_to_sheet_anchor_x, @partners_to_sheet_anchor_y)
    partners_to_clew = Vector2.new(-@sail.clew_to_mast_center, clew_above_partners)
    clew_to_sheet_anchor = partners_to_clew - partners_to_sheet_anchor
    @clew_distance_to_sheet_anchor = clew_to_sheet_anchor.magnitude
    @clew_angle_to_sheet_anchor = clew_to_sheet_anchor.angle

    puts min_sheet_distance_buffer: @clew_distance_to_sheet_anchor - @sail.inner_sheet_distance
    puts clew_angle_to_sheet_anchor: @clew_angle_to_sheet_anchor.to("deg")

    sections = Hash.new{ |hash, key| hash[key] = {} }
    safety_factors = mast.safety_factors("ft"){ |pos| mast_moment(pos) }
    safety_factors.each do |position, section_safeties|
      section_safeties.each do |section, safety_factor|
        sections[section][position] = safety_factor
      end
    end

    sections.each do |section, safeties|
      puts safeties.keys.map(&:scalar).join(",")
      puts safeties.values.join(",")
    end
  end

  def mast_moment(distance_from_partners)
    sail_start = @tack_above_partners
    zero_length = Unit.new("0 in")
    active_sail_height = [distance_from_partners - sail_start, zero_length].max
    #NOTE: This approximates by assuming a rectangular sail
    total_sail_height = @sail.tack_to_peak.y
    active_sail_ratio = 1 - (active_sail_height / total_sail_height)
    active_sail_area = active_sail_ratio * @sail.area
    active_sail_center = sail_start + (total_sail_height - active_sail_height) / 2
    sail_moment = (active_sail_area / @sail.area) * @max_force_on_sail_center_of_area * active_sail_center

    if distance_from_partners >= zero_length
      sail_moment
    else
      sail_moment * (1 + distance_from_partners / @mast.foot)
    end
  end

  def draw_sail
    sail.draw_to_file("sail.svg", @mast, Vector2.new(@sail.tack_to_mast_center, -@tack_above_partners))
  end

  def setup_mast(options)
    upper_mast = Engineering::VariableSpar.new(options[:upper])

    def to_eighths(length)
      Unit.new(((Unit.new(length).to("in").scalar * 8).to_i / 8).to_f, "in")
    end

    def make_tube(outer_diameter, wall_thickness)
      Engineering::CrossSection.create(
        type: "Tube",
        outer_diameter: to_eighths(outer_diameter),
        wall_thickness: to_eighths(wall_thickness)
      )
    end

    lower_options = options[:lower]

    partners_pos    = -Unit.new(lower_options[:foot])
    partners_length = Unit.new(lower_options.delete(:partners_length))
    overlap         = Unit.new(lower_options.delete(:overlap))
    foot_ratio      = lower_options.delete(:foot_ratio)

    partners_diameter = upper_mast.cross_section(Unit.new("0 in")).inner_diameter
    top_diameter = to_eighths(upper_mast.cross_section(overlap).inner_diameter)

    foot      = make_tube(partners_diameter * foot_ratio, "2 in")
    partners  = make_tube(partners_diameter, to_eighths(partners_diameter / 2))
    head      = make_tube(top_diameter, "2 in")

    ap({
      foot: {
        outer: foot.outer_diameter,
        inner: foot.inner_diameter
      },
      partners: {
        outer: partners.outer_diameter,
        inner: partners.inner_diameter
      },
      head: {
        outer: head.outer_diameter,
        inner: head.inner_diameter
      }
    })

    lower_mast = Engineering::VariableSpar.new(
      material: lower_options[:material],
      section_type: upper_mast.section_type,
      cross_sections: {
        Unit.new("0 in")                => foot,
        partners_pos - partners_length  => partners,
        partners_pos                    => partners,
        partners_pos + overlap          => head,
      }
    )

    Engineering::CompositeSpar.new(
      sections: [
        {
          spar: lower_mast,
          foot: options[:lower][:foot],
          name: "Lower"
        },
        {
          spar: upper_mast,
          foot: options[:upper][:foot],
          name: "Upper"
        },
      ]
    )
  end

end
