require "options_initializer"

class Boat
  include OptionsInitializer

  HULL_SPEED_COEFFICIENT = 1.34 #kt/ft^0.5, which ruby-units can't represent as of writing this

  attr_reader *%i(
    saltwater_displaced
    ballast_ratio
    capsize_screening_value
    stability_range
    displacement_to_length
    max_buoyancy_lever
    estimated_max_righting_moment
    water_pressure_at_keel
    comfort_ratio
    hull_speed
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
    waterline_above_center_of_mass: { units: "in" },
  ) do |options|
    #volume of seawater displaced by the boat
    @saltwater_displaced = (@displacement / Constants.saltwater_density).to("m^3")
    #ratio of ballast to total displacement
    @ballast_ratio = @ballast / @displacement

    #simplified composite value that represents the stability of the boat
    @capsize_screening_value = @maximum_beam.to("ft") / (@saltwater_displaced**(1/3)).to("ft")

    screening_stability_value = maximum_beam.to("in")**2 / (ballast_ratio * draft_of_canoe_body * saltwater_displaced**(1/3)).to("in^2")
    #angle at which the boat loses upright stability
    @stability_range = Unit.new(110 + (400 / (screening_stability_value - 10)), "degrees")
    #composite ratio relating the displacement to the waterline length
    @displacement_to_length = @displacement.to("long-tons").scalar / (@length_at_waterline.to("ft").scalar / 100)**3
    #buoyancy lever specified on construction, if it exists
    @max_buoyancy_lever = @max_buoyancy_lever || @maximum_beam / 4
    #righting moment if the boat was knocked down, but the center of buoyancy stayed the same
    @estimated_max_righting_moment = @max_buoyancy_lever * @displacement * Unit.new("1 gee")
    #saltwater pressure outside the hull at the top of the keel
    @water_pressure_at_keel = (Constants.saltwater_density * Constants.gravity * @draft_of_canoe_body).to("psi")
    #Ted Brewer's comfort ratio. Ranges from 5 for a light daysailer to 60+ for super heavy boats. Cruisers are often mid-30s. See http://www.tedbrewer.com/yachtdesign.html
    @comfort_ratio = @displacement.to("lbs").scalar / (0.65 * (0.7 * @length_at_waterline.to("ft").scalar + 0.3 * @length_overall.to("ft").scalar) * @maximum_beam.to("ft").scalar**1.333)
    #Theoretical maximum speed of displacement craft due to bow wave
    @hull_speed = Unit.new(HULL_SPEED_COEFFICIENT * Math.sqrt(@length_at_waterline.to("ft").scalar), "knots")
  end
end
