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
    [:clew_above_waterline, "ft"],
    [:minimum_safe_roll_angle, "degrees"],
]

puts ExportHelper.generate_csv(rig, output_format)
