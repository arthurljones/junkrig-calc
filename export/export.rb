require_relative "../boilerplate"
require "export_helper"

require "rig"
require "boat"
require "sail/sail"

data = load_yaml_data_file("boat.yml")

rig = Rig.new(data[:rig])
boat = rig.boat
sail = rig.sail

rig.draw_sail

puts
puts "Boat"
output_format = [
    [:displacement, {units: "lbs"}],
    [:ballast, {units: "lbs"}],
    [:draft_of_canoe_body, {units: "in"}],
    [:maximum_beam, {units: "in"}],
    [:minimum_freeboard, {units: "in"}],
    [:bow_height_above_water, {units: "in"}],
    [:length_overall, {units: "in"} ],
    [:length_at_waterline, {units: "in"}],
    [:max_buoyancy_lever, {units: "in"}],
    [:foredeck_angle, {units: "deg"}],
    [:waterline_above_center_of_mass, {units: "in"}],
    [],
    [:saltwater_displaced, {units: "ft^3"}],
    [:maximum_beam, {units: "m"}],
    [:ballast_ratio, {}],
    [:stability_range, {units: "deg"}],
    [:displacement_to_length, {}],
    [:estimated_max_righting_moment, {units: "in*lbf"}],
    [:water_pressure_at_keel, {units: "psi"}],
    [:comfort_ratio, {}],
    [:hull_speed, {units: "knots"}]
]
puts ExportHelper.generate_csv(boat, output_format)

puts
puts "Sail"
output_format = [
    [:parallelogram_luff, {units: "ft"}],
    [:batten_length, {units: "ft"}],
    [:lower_panel_count, {units: "nil"}],
    [:head_panel_count, {units: "nil"}],
    [:yard_angle, {units: "deg"}],
    [],
    [:lower_panel_luff, {units: "ft"}],
    [:head_panel_luff, {units: "in"}],
    [:total_luff, {units: "ft"}],
    [:main_leech, {units: "ft"}],
    [:parallelogram_width, {units: "ft"}],
    [:circumference, {units: "ft"}],
    [:luff_to_batten_length, {}],
    [],
    [:tack_angle, {units: "deg"}],
    [:clew_rise, {units: "ft"}],
    [:center, :y, { units: "ft", label: :center_above_tack }],
    [:center, :x, { units: "ft", label: :center_before_tack }],
    [:peak, :y, { units: "ft", label: :peak_above_tack }],
    [:aspect_ratio, {}],
    [],
    [:sling_point_to_mast_center, {units: "ft"}],
    [:sling_point, :y, { units: "ft", label: :sling_point_above_tack }],
    [:tack_to_mast_center, {units: "ft"}],
    [:clew_to_mast_center, {units: "ft"}],
    [:sail_balance_forward_of_mast, {}],
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
    [:sail_area, {units: "ft^2"}],
    [:sail_area, {units: "m^2"}],
]
puts ExportHelper.generate_csv(objects, output_format)

output_format = [
    [],
    [{label: "Mast"}],
    [:mast, :length, {units: "ft"}],
    [:mast, :head, {units: "ft", label: :above_partners}],
    [:partners_above_waterline, {units: "ft"}],
    [:mast, :mass, {units: "lbs", label: :mast_mass}],
    [:mast, :windage, {units: "ft^2", label: :windage_todo}], #TODO!
    [],
    [{label: "Rig"}],
    [:partners_above_center_of_mass, {units: "ft"}],
    [:tack_above_partners, {units: "ft"}],
    [:sail_area_to_displacement, {}],
    [:s_number, {}],
    [:center_of_area_above_partners, {units: "in"}],
    [:center_of_area_above_center_of_mass, {units: "in"}],
    [:max_force_on_sail_center_of_area, {units: "lbf"}],
    [],
    [:max_moment_at_partners, {units: "in*lbf"}],
    [:yield_moment_at_partners, {units: "in*lbf"}],
    [:partners_safety_factor, {}],
    [],
    [:max_moment_at_sleeve, {units: "in*lbf"}],
    [:yield_moment_at_sleeve, {units: "in*lbf"}],
    [:sleeve_safety_factor, {}],
    [],
    [:minimum_safe_roll_angle, {units: "degrees"}],
    [:mast_height_above_sling_point, {units: "ft"}],
    [:mast_tip_to_batten_length, {}],
    [:max_halyard_lead_angle, {units: "degrees"}],
]
puts ExportHelper.generate_csv(rig, output_format)
