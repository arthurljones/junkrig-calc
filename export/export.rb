require_relative "../boilerplate"
require "export_helper"

require "rig"
require "boat"
require "sail/sail"

data = load_yaml_data_file("boat.yml")

boat = Boat.new(data[:boat])
mast = Mast.new(data[:mast])
sail = Sail::Sail.new(data[:sail])

sail.draw_to_file("sail.svg")

options = data[:rig]
options[:mast] = mast
options[:boat] = boat
options[:sail] = sail
rig = Rig.new(options)

puts
puts "Boat"
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
    [:waterline_above_center_of_mass, "in"],
    [nil, nil],
    [:saltwater_displaced, "ft^3"],
    [:maximum_beam, "m"],
    [:ballast_ratio, nil],
    [:stability_range, "deg"],
    [:displacement_to_length, nil],
    [:estimated_max_righting_moment, "in*lbf"],
    [:water_pressure_at_keel, "psi"],
    [:comfort_ratio, nil],
    [:hull_speed, "knots"]
]
puts ExportHelper.generate_csv(boat, output_format)

puts
puts "Mast"
output_format = [
    [:length, "ft"],
    [:foot_above_waterline, "ft"],
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
    [nil, nil],
    [:mass, "lbs"],
    [:windage, "ft^2"],
]
puts ExportHelper.generate_csv(mast, output_format)

puts
puts "Sail"
output_format = [
    [:parallelogram_luff, "ft"],
    [:batten_length, "ft"],
    [:lower_panel_count, "nil"],
    [:head_panel_count, "nil"],
    [:yard_angle, "deg"],
    [nil],
    [:lower_panel_luff, "ft"],
    [:head_panel_luff, "in"],
    [:total_luff, "ft"],
    [:total_leech, "ft"],
    [:parallelogram_width, "ft"],
    [:circumference, "ft"],
    [:luff_to_batten_length, nil],
    [nil],
    [:tack_angle, "deg"],
    [:clew_rise, "ft"],
    [:center_above_tack, "ft", ->(obj){ obj.center.y }],
    [:center_before_tack, "ft", ->(obj){ obj.center.x }],
    [:peak_above_tack, "ft", ->(obj){ obj.tack_to_peak.y }],
    [:aspect_ratio, nil],
    [nil],
    [:sling_point_to_mast_center, "ft"],
    [:sling_point_above_tack, "ft", ->(obj){ obj.sling_point.y }],
    [:tack_to_mast_center, "ft"],
    [:clew_to_mast_center, "ft"],
    [:sail_balance_forward_of_mast, nil],
]

puts ExportHelper.generate_csv(sail, output_format)

class ReefedPanelArea
    attr_reader :reefed_panels, :sail_area
    def initialize(reefed, area)
        @reefed_panels = reefed
        @sail_area = area
    end
end

objects = (0..sail.total_panels).collect{|p| ReefedPanelArea.new(p, sail.reefed_area(p))}
output_format = [
    [:reefed_panels, nil],
    [:sail_area, "ft^2"],
    [:sail_area, "m^2"],
]

puts
puts ExportHelper.generate_csv(objects, output_format)

puts
puts "Rig"
output_format = [
    [:partners_above_center_of_mass, "ft"],
    [:tack_above_partners, "ft"],
    [:sail_area_to_displacement, nil],
    [:s_number, nil],
    [:clew_above_waterline, "ft"],
    [:center_of_area_above_partners, "in"],
    [:center_of_area_above_center_of_mass, "in"],
    [:max_force_on_sail_center_of_area, "lbf"],
    [:max_moment_at_partners, "in*lbf"],
    [:yield_moment_at_partners, "in*lbf"],
    [:safety_factor, nil],
    [nil],
    [:minimum_safe_roll_angle, "degrees"],
    [:mast_height_above_sling_point, "ft"],
    [:mast_tip_to_batten_length, nil],
    [:max_halyard_lead_angle, "degrees"],
]
puts ExportHelper.generate_csv(rig, output_format)
