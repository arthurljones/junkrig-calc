#Replaces calculations from the RBCalc sheet until fully moved to ruby
require_relative "../boilerplate"
require "engineering/cross_sections/rounded_box"

columns = %i(height width wall_thickness corner_radius defect_width gusset_size)

rb_input = {
    :mast_partners => [10, 10, 1.5, 3, 0.75, 1.5],
    :mast_tip => [4.25, 4.25, 1.5, 1.5, 0.31875, 0.25],
    :mast_foot => [5.25, 5.25, 1.5, 1.5, 0.39375, 0.25],
    :box_yard_sling => [5, 3.25, 1, 1, 0, 0],
    :box_yard_tips => [3.25, 2.25, 1, 1, 0, 0],
    :solid_yard_sling => [5, 3.25, -1, 0.75, 0, 0],
    :solid_yard_tips => [3.25, 2.75, -1, 0.5, 0, 0],
    :solid_batten => [2.75, 2, -1, 0.375, 0, 0],
    :box_batten => [2.75, 2, 0.75, 0.375, 0, 0],
    :weak_full_2x4 => [1.5, 3.5, -1, 0.125, 0, 0],
    :weak_half_2x4 => [1.5, 1.6875, -1, 0.125, 0, 0],
    :weak_stave => [1, 1.5, -1, 0, 0, 0],
    :weak_2x4_pair => [3, 3.5, -1, 0.125, 0, 0],
    :strong_full_2x4 => [3.5, 1.5, -1, 0.125, 0, 0],
    :strong_half_2x4 => [1.6875, 1.5, -1, 0.125, 0, 0],
    :strong_stave => [1.5, 1, -1, 0, 0, 0],
    :strong_2x4_pair => [3.5, 3, -1, 0.125, 0, 0]
}

output = {}

rb_input.each do |name, raw_input|
    options = {}
    columns.each_with_index do |column, index|
        value = raw_input[index]
        options[column] = "#{value}in" unless column == :wall_thickness && value < 0
    end
    output[name] = Engineering::CrossSections::RoundedBox.new(options)
end

puts "Name," + output.keys.join(",")
puts "Total Moment of Area (in⁴),=" + output.values.collect{|val| val.second_moment_of_area.to("in^4").scalar}.join(",=")
puts "Cross Section (in²),=" + output.values.collect{|val| val.area.to("in^2").scalar}.join(",=")
puts "Distance to Extreme Fiber (in),=" + output.values.collect{|val| val.extreme_fiber_radius.to("in").scalar}.join(",=")
puts "Section Modulus (in^3),=" + output.values.collect{|val| val.elastic_section_modulus.to("in^3").scalar}.join(",=")
puts "Outside Circumference (in),=" + output.values.collect{|val| val.circumference.to("in").scalar}.join(",=")
