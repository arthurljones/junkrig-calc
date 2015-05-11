require_relative "../boilerplate"
require "sail/sail"
require "export_helper"

sail = Sail::Sail.new(load_yaml_data_file("sail.yml"))
output_format = [
    [:area, "ft^2"],
    [:panel_width, "ft"],
    [:total_leech, "ft"],
    [:center_above_tack, "ft"],
    [:center_before_tack, "ft"],
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
]

puts
puts ExportHelper.generate_csv(objects, output_format)
