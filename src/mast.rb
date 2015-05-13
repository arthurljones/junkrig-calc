require "options_initializer"

require "engineering/cross_section"

class Mast
  include OptionsInitializer

  attr_reader *%i(
    above_partners
    below_partners
    pivot_above_foot
    bury
    partners_center_above_waterline
    partners_above_center_of_mass
    mast_tip_above_center_of_mass
  )

  options_initialize(
    length: { units: "in" },
    foot_above_waterline: { units: "in" },
    waterline_above_center_of_mass: { units: "in" },
    partners_center_above_foot: { units: "in" },
    partners_length: { units: "in" },
    pivot_above_partners_center: { units: "in" },
    foot:     { constructor: ->(opts) { Engineering::CrossSection.create(opts) if opts  } },
    partners: { constructor: ->(opts) { Engineering::CrossSection.create(opts) if opts }, required: false },
    masthead: { constructor: ->(opts) { Engineering::CrossSection.create(opts) if opts  } },
  ) do |options|
    half_partners = @partners_length / 2
    @above_partners = @length - @partners_center_above_foot - half_partners
    @below_partners = @length - @above_partners - half_partners
    @pivot_above_foot = @pivot_above_partners_center + @partners_center_above_foot
    @bury = @partners_center_above_foot / @length
    @partners_center_above_waterline = @foot_above_waterline + @partners_center_above_foot
    @partners_above_center_of_mass = @partners_center_above_waterline + @waterline_above_center_of_mass
    @mast_tip_above_center_of_mass = @length + @foot_above_waterline + @waterline_above_center_of_mass
  end
end
