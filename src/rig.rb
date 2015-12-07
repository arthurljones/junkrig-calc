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

    #pos : { section: safety_factor }
    #[pos], [name, factors...], [name, factors...], ...

    print_safety_factors
  end

  def print_safety_factors
    safety_factors = mast.safety_factors("in"){ |pos| mast_moment(pos) }
    puts (["Pos (in)"] + safety_factors.delete(:positions).map(&:scalar)).join(",")
    safety_factors.each do |section, values|
      puts ([section.name] + values).join(",")
    end
  end

  def mast_moment(distance_from_partners)
    sail_start = @tack_above_partners
    zero_length = Unit.new("0 in")
    above_partners = [distance_from_partners, zero_length].max
    active_sail_height = [above_partners - sail_start, zero_length].max
    #NOTE: This approximates by assuming a rectangular sail
    total_sail_height = @sail.tack_to_peak.y
    active_sail_ratio = 1 - (active_sail_height / total_sail_height)
    active_sail_area = active_sail_ratio * @sail.area
    active_sail_center = sail_start + total_sail_height - (total_sail_height - active_sail_height) / 2
    active_sail_lever = active_sail_center - above_partners
    sail_moment = (active_sail_area / @sail.area) * @max_force_on_sail_center_of_area * active_sail_lever

    if distance_from_partners < zero_length
      sail_moment *= (1 - distance_from_partners / @mast.foot)
    end

    linear_minimum = Unit.new("200 lbf") * (@mast.head - above_partners)
    absolute_minimum = Unit.new("200 ft*lbf")
    [sail_moment, linear_minimum, absolute_minimum].max
  end

  def draw_sail
    sail.draw_to_file("sail.svg", @mast, Vector2.new(@sail.tack_to_mast_center, -@tack_above_partners))
  end

  def setup_mast(options)
    lower_mast = Engineering::VariableSpar.new(options[:lower])
    upper_mast = Engineering::VariableSpar.new(options[:upper])

    Engineering::CompositeSpar.new(
      sections: [
        {
          spar: lower_mast,
          foot: options[:lower][:foot],
          name: "Lower"
        },
        {
          spar: upper_mast,
          foot: lower_mast.length + Unit.new(options[:lower][:foot]) - Unit.new("2 ft"),
          name: "Upper"
        },
      ]
    )
  end

end
