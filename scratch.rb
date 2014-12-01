require_relative "boilerplate"

require "boat"

boat = Boat.from_file("boat.yml")
ap boat
ap Math.cos(boat.foredeck_angle)
ap boat.saltwater_displaced
ap boat.ballast_ratio.to_f
ap boat.stability_value
ap boat.stability_range
ap boat.displacement_to_length.to_f
ap boat.max_righting_moment
ap boat.water_pressure_at_keel
