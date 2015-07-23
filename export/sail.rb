require_relative "../boilerplate"
require "sail/sail"
require "export_helper"

data = load_yaml_data_file("boat.yml")
sail = Sail::Sail.new(data[:sail])
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
