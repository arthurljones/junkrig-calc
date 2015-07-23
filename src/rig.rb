require "options_initializer"
require_relative "mast"
require_relative "boat"
require_relative "sail/sail"

class Rig
  include OptionsInitializer

  MASTHEAD_TO_PARTNERS_MINIMUM = 0.4
  MASTHEAD_TO_FOOT_MINIMUM = 0.5

  attr_reader *%i(
    clew_above_waterline
    minimum_safe_roll_angle
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
  end
end
