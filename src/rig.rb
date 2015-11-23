require "options_initializer"
require_relative "mast"
require_relative "boat"
require_relative "sail/sail"

class Rig
  include OptionsInitializer

  #MASTHEAD_TO_PARTNERS_MINIMUM = 0.4
  #MASTHEAD_TO_FOOT_MINIMUM = 0.5

  attr_reader *%i(
    partners_above_center_of_mass
    mast_tip_above_center_of_mass
    clew_above_waterline
    minimum_safe_roll_angle
    center_of_area_above_partners
    center_of_area_above_center_of_mass
    max_force_on_sail_center_of_area
    max_moment_at_partners
    yield_moment_at_partners
    safety_factor
    sail_area_to_displacement
    s_number
    mast_height_above_sling_point
    mast_tip_to_batten_length
    max_halyard_lead_angle
  )

  options_initialize(
    tack_above_partners: { units: "in" },
    mast: { },
    sail: { },
    boat: { },
  ) do |options|
      unless (Boat === @boat)
        @boat = Boat.new(@boat)
      end

      unless (Mast === @mast)
        @mast = Mast.new(@mast)
      end

      unless (Sail::Sail === @sail)
        @sail = Sail::Sail.new(@sail)
      end

      @partners_above_center_of_mass = @mast.partners_center_above_waterline + @boat.waterline_above_center_of_mass
      @mast_tip_above_center_of_mass = @mast.length + @mast.foot_above_waterline + @boat.waterline_above_center_of_mass

      @clew_above_waterline = @tack_above_partners + @mast.partners_center_above_waterline + @sail.clew_rise
      @minimum_safe_roll_angle = Unit.new(Math.atan2(@clew_above_waterline, @sail.clew_to_mast_center), "rad")
      @center_of_area_above_partners = @tack_above_partners + @sail.center.y
      @center_of_area_above_center_of_mass = @partners_above_center_of_mass + @center_of_area_above_partners
      @max_force_on_sail_center_of_area = @boat.estimated_max_righting_moment / @center_of_area_above_center_of_mass

      @max_moment_at_partners = @max_force_on_sail_center_of_area * @center_of_area_above_partners
      @yield_moment_at_partners = @mast.partners.elastic_section_modulus * @mast.material.yield_strength
      @safety_factor = @yield_moment_at_partners / @max_moment_at_partners

      @sail_area_to_displacement = (@sail.area / (@boat.saltwater_displaced**(2/3))).to(Unit.new(1))
      dlr = @boat.displacement_to_length
      sad = @sail_area_to_displacement
      @s_number = 3.972 * 10 ** (-dlr/526 + 0.691 * (Math::log10(sad)-1) ** 0.8)

      @mast_height_above_sling_point = @mast.length - (@mast.partners_center_above_foot + @tack_above_partners + @sail.sling_point.y)
      @mast_tip_to_batten_length = @mast_height_above_sling_point / @sail.batten_length
      @max_halyard_lead_angle = Unit.new(Math.atan2(@sail.sling_point_to_mast_center - @mast.masthead.extreme_fiber_radius,
        @mast_height_above_sling_point), "rad")

  end
end
