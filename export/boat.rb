require_relative "../boilerplate"
require "boat"
require "export_helper"

boat = Boat.new(load_yaml_data_file("boat.yml")[:boat])
output_format = [
    [:displacement, "lbs"],
    [:ballast, "lbs"],
    [:draft_of_canoe_body, "in"],
    [:maximum_beam, "in"],
    [:minimum_freeboard, "in"],
    [:bow_height_above_water, "in"],
    [:length_overall, "in" ],
    [:length_at_waterline, "in"],
    [:max_buoyancy_lever, "in"],
    [:foredeck_angle, "deg"],
    [nil, nil],
    [:saltwater_displaced, "ft^3"],
    [:maximum_beam, "m"],
    [:ballast_ratio, nil],
    [:stability_range, "deg"],
    [:displacement_to_length, nil],
    [:estimated_max_righting_moment, "in*lbs"],
    [:water_pressure_at_keel, "psi"],
    [:comfort_ratio, nil]
]

puts ExportHelper.generate_csv(boat, output_format)
