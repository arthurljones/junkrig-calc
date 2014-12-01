require "options_initializer"

class Boat
  include OptionsInitializer

  options_initialize(
    displacement: { units: "lbs" },
    ballast: { units: "lbs" },
    draft_of_canoe_body: { units: "in" },
    maximum_beam: { units: "in" },
    minimum_freeboard: { units: "in" },
    bow_height_above_water: { units: "in" },
    length_overall: { units: "in" },
    length_at_waterline: { units: "in" },
    buoyancy_lever: { :required => false, units: "in" },
    foredeck_angle: { units: "deg"},
  ) do |options|

  end

  def self.from_file(file)
    new(YAML.load_file(file).with_indifferent_access)
  end

  def saltwater_displaced
    (displacement / Constants.saltwater_density).to("m^3")
  end

  def ballast_ratio
    ballast / displacement
  end

  def stability_value
    maximum_beam.to("m")**2 / (ballast_ratio * draft_of_canoe_body.to("m") * saltwater_displaced.to("m^3")**(1/3))
  end

  def stability_range
    Unit(110 + (400 / (stability_value - 10)), "deg")
  end

  def displacement_to_length
    displacement.to("long-tons").scalar / (length_at_waterline.to("ft").scalar / 100)**3
  end

  def buoyancy_lever
    @buoyancy_lever || maximum_beam / 4
  end

  def max_righting_moment
    buoyancy_lever * displacement
  end

  def water_pressure_at_keel
    (Constants.saltwater_density * Constants.gravity * draft_of_canoe_body).to("psi")
  end

end
