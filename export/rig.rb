require_relative "../boilerplate"
require "rig"
require "export_helper"

data = load_yaml_data_file("boat.yml")
options = data[:rig]
options[:mast_data] = data[:mast]
options[:boat_data] = data[:boat]
options[:sail_data] = data[:sail]
rig = Rig.new(options)
output_format = [
    [:tack_above_partners, "ft"],
    [:sail_area_to_displacement, nil],
    [:s_number, nil],
    [:clew_above_waterline, "ft"],
    [:center_of_area_above_partners, "in"],
    [:center_of_area_above_center_of_mass, "in"],
    [:max_force_on_sail_center_of_area, "lbs"],
    [:max_moment_at_partners, "in*lbs"],
    [nil],
    [:minimum_safe_roll_angle, "degrees"],
    [:mast_height_above_sling_point, "ft"],
    [:mast_tip_to_batten_length, nil],
    [:max_halyard_lead_angle, "degrees"],
]

puts ExportHelper.generate_csv(rig, output_format)
