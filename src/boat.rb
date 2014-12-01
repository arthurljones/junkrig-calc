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
    buoyancy_lever: { units: "in" },
    foredeck_angle: { units: "deg"},
  ) do |options|

  end

  def self.from_file(file)
    new(YAML.load_file(file).with_indifferent_access)
  end

end
