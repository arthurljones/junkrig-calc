require "options_initializer"

class Boat
  include OptionsInitializer

  attr_reader *%i(
    saltwater_displaced
    ballast_ratio
    capsize_screening_value
    stability_range
    displacement_to_length
    max_buoyancy_lever
    estimated_max_righting_moment
    water_pressure_at_keel
  )

  options_initialize(
    displacement: { units: "lbs" },
    ballast: { units: "lbs" },
    draft_of_canoe_body: { units: "in" },
    maximum_beam: { units: "in" },
    minimum_freeboard: { units: "in" },
    bow_height_above_water: { units: "in" },
    length_overall: { units: "in" },
    length_at_waterline: { units: "in" },
    max_buoyancy_lever: { :required => false, units: "in" },
    foredeck_angle: { units: "deg"},
  ) do |options|
    #volume of seawater displaced by the boat
    @saltwater_displaced = (@displacement / Constants.saltwater_density).to("m^3")
    #ratio of ballast to total displacement
    @ballast_ratio = @ballast / @displacement

    #simplified composite value that represents the stability of the boat
    @capsize_screening_value = @maximum_beam.to("ft") / (@saltwater_displaced**(1/3)).to("ft")

    screening_stability_value = maximum_beam.to("in")**2 / (ballast_ratio * draft_of_canoe_body * saltwater_displaced**(1/3)).to("in^2")
    #angle at which the boat loses upright stability
    @stability_range = Unit(110 + (400 / (screening_stability_value - 10)), "degrees")
    #composite ratio relating the displacement to the waterline length
    @displacement_to_length = @displacement.to("long-tons").scalar / (@length_at_waterline.to("ft").scalar / 100)**3
    #buoyancy lever specified on construction, if it exists
    @max_buoyancy_lever = @max_buoyancy_lever || @maximum_beam / 4
    #righting moment if the boat was knocked down, but the center of buoyancy stayed the same
    @estimated_max_righting_moment = @max_buoyancy_lever * @displacement
    #saltwater pressure outside the hull at the top of the keel
    @water_pressure_at_keel = (Constants.saltwater_density * Constants.gravity * @draft_of_canoe_body).to("psi")
  end

  def self.from_file(file)
    new(YAML.load_file(file).with_indifferent_access)
  end
end
