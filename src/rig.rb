require "options_initializer"
require_relative "mast"
require_relative "boat"
require_relative "sail/sail"

class Rig
  include OptionsInitializer

  #MASTHEAD_TO_PARTNERS_MINIMUM = 0.4
  #MASTHEAD_TO_FOOT_MINIMUM = 0.5

  attr_reader *%i(
    clew_above_waterline
    minimum_safe_roll_angle
    center_of_area_above_partners
    center_of_area_above_center_of_mass
    max_force_on_sail_center_of_area
    max_moment_at_partners
    sail_area_to_displacement
    mast_height_above_sling_point
    mast_tip_to_batten_length
    max_halyard_lead_angle
  )

  options_initialize(
    tack_above_partners: { units: "in" },
    mast_data: { },
    sail_data: { },
    boat_data: { },
  ) do |options|
      @mast = Mast.new(@mast_data)
      @sail = Sail::Sail.new(@sail_data)
      @boat = Boat.new(@boat_data)

      @clew_above_waterline = @tack_above_partners + @mast.partners_center_above_waterline + @sail.clew_rise
      @minimum_safe_roll_angle = Unit.new(Math.atan2(@clew_above_waterline, @sail.clew_to_mast_center), "rad")
      @center_of_area_above_partners = @tack_above_partners + @sail.center.y
      @center_of_area_above_center_of_mass = @mast.partners_above_center_of_mass + @center_of_area_above_partners
      @max_force_on_sail_center_of_area = @boat.estimated_max_righting_moment / @center_of_area_above_center_of_mass
      @max_moment_at_partners = @max_force_on_sail_center_of_area * @center_of_area_above_partners

      @sail_area_to_displacement = @sail.area / (@boat.saltwater_displaced**(2/3))
      @mast_height_above_sling_point = @mast.length - (@mast.partners_center_above_foot + @tack_above_partners + @sail.sling_point.y)
      @mast_tip_to_batten_length = @mast_height_above_sling_point / @sail.batten_length
      @max_halyard_lead_angle = Unit.new(Math.atan2(@sail.sling_point_to_mast_center - @mast.masthead.extreme_fiber_radius,
        @mast_height_above_sling_point), "rad")
  end
end
