require_relative "../boilerplate"
require "mast"
require "export_helper"

mast = Mast.new(load_yaml_data_file("boat.yml")[:mast])
output_format = [
    [:length, "ft"],
    [:foot_above_waterline, "ft"],
    [:waterline_above_center_of_mass, "ft"],
    [:partners_center_above_foot, "ft"],
    [:partners_length, "ft"],
    [:pivot_above_partners_center, "ft"],
    [nil, nil],
    [:above_partners, "ft"],
    [:above_partners, "m"],
    [:below_partners, "ft"],
    [:pivot_above_foot, "ft"],
    [:bury, nil],
    [:partners_center_above_waterline, "ft"],
    [:partners_above_center_of_mass, "ft"],
]

puts ExportHelper.generate_csv(mast, output_format)
