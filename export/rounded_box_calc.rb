#Replaces calculations from the RBCalc sheet until fully moved to ruby
require_relative "../boilerplate"
require "engineering/cross_sections/rounded_box"
require "export_helper"

columns = %i(height width wall_thickness corner_radius defect_width gusset_size)

input = {
    :weak_full_2x4 => [1.5, 3.5, -1, 0.125, 0, 0],
    :weak_half_2x4 => [1.5, 1.6875, -1, 0.125, 0, 0],
    :weak_stave => [1, 1.5, -1, 0, 0, 0],
    :weak_2x4_pair => [3, 3.5, -1, 0.125, 0, 0],
    :strong_full_2x4 => [3.5, 1.5, -1, 0.125, 0, 0],
    :strong_half_2x4 => [1.6875, 1.5, -1, 0.125, 0, 0],
    :strong_stave => [1.5, 1, -1, 0, 0, 0],
    :strong_2x4_pair => [3.5, 3, -1, 0.125, 0, 0],
    :strong_composite => [5.5, 1.75, -1, 0, 0, 0],
    :weak_composite => [1.75, 5.5, -1, 0, 0, 0],
}

#puts "," + input.keys.join(",")

objects = input.map do |name, raw_input|
    options = {}
    columns.each_with_index do |column, index|
        value = raw_input[index]
        options[column] = "#{value}in" unless column == :wall_thickness && value < 0
    end
    Engineering::CrossSections::RoundedBox.new(options)
end

output_format = [
    ["height", "in"],
    ["width", "in"],
    ["wall_thickness", "in"],
    ["corner_radius", "in"],
    ["defect_width", "in"],
    ["gusset_size", "in"],
    [nil],
    ["second_moment_of_area", "in^4"],
    ["area", "in^2"],
    ["extreme_fiber_radius", "in"],
    ["elastic_section_modulus", "in^3"],
    ["circumference", "in"]
]

puts ExportHelper.generate_csv(objects, output_format)
