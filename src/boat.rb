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

  "returns the volume of seawater displaced by the boat"
  def saltwater_displaced
    (displacement / Constants.saltwater_density).to("m^3")
  end

  "returns the ratio of ballast to total displacement"
  def ballast_ratio
    ballast / displacement
  end

  "returns a composite value that represents the stability of the boat"
  def screening_stability_value
    maximum_beam.to("in")**2 / (ballast_ratio * draft_of_canoe_body * saltwater_displaced**(1/3)).to("in^2")
  end

  "returns the angle at which the boat loses upright stability"
  def stability_range
    Unit(110 + (400 / (screening_stability_value - 10)), "degrees")
  end

  "returns a composite ratio relating the displacement to the waterline length"
  def displacement_to_length
    displacement.to("long-tons").scalar / (length_at_waterline.to("ft").scalar / 100)**3
  end

  "returns the buoyancy lever specified on construction, if it exists"
  def buoyancy_lever
    @buoyancy_lever || maximum_beam / 4
  end

  "returns the righting moment if the boat was knocked down, but the center of buoyancy stayed the same"
  def estimated_max_righting_moment
    #TODO: This assumes that the center of buoyancy doesn't move as the boat heels, which is technically wrong.
    buoyancy_lever * displacement
  end

  "returns the saltwater pressure outside the hull at the top of the keel"
  def water_pressure_at_keel
    (Constants.saltwater_density * Constants.gravity * draft_of_canoe_body).to("psi")
  end

end
