require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"
require "sheet/system"

def calculate_max_tension
  elongation_at_break = 0.167 #Elongation to breaking stress
  tensile_strength = Unit.new("2650 lbf")
  modulus_of_elasticity = Unit.new("2 GPa")
  rope_diameter = Unit.new(3/8, "in")
  solid = Math::PI * (rope_diameter / 2) ** 2
  strand_radius = rope_diameter / (2 * 2.154) #Circle packing ratio from https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
  theoretical = 3 * Math::PI * strand_radius ** 2

  cross_section = (tensile_strength / (elongation_at_break * modulus_of_elasticity)).to("in^2")
  puts area: cross_section, solid: solid, theoretical: theoretical, ratio: cross_section/solid
end


span_length = Unit.new("10 in")
clew_height = Unit.new("50 in")

anchor = Sheet::AnchorPoint.new(name: "anchor", position: ["0 in", "0 in"])
batten0 = Sheet::AnchorPoint.new(name: "batten0", position: ["0 in", clew_height])
batten1 = Sheet::AnchorPoint.new(name: "batten1", position: ["0 in", clew_height])
upper_block = Sheet::FreePoint.new(name: "upper_block", position: ["1 in", clew_height])
lower_block = Sheet::FreePoint.new(name: "lower_block", position: ["2 in", clew_height])
bitter_end = Sheet::FreePoint.new(name: "bitter_end", position: ["0 in", "-5 in"])

upper_span = Sheet::Segment.new(
  name: "upper_span",
  max_tension: "50 lbf",
  length: span_length,
  points: [batten1, upper_block])

lower_span = Sheet::Segment.new(
  name: "lower_span",
  max_tension: "50 lbf",
  length: span_length * 1.4,
  points: [batten0, lower_block, upper_block, lower_block])

sheet = Sheet::Segment.new(
  name: "sheet",
  max_tension: "50 lbf",
  length: clew_height + span_length,
  points: [lower_block, anchor, bitter_end])

upper_positions = []
lower_positions = []
upper_tensions = []
lower_tensions = []
sheet_tensions = []

sheet_system = Sheet::System.new

sheet_system.add_points([anchor, batten0, batten1, upper_block, lower_block, bitter_end])
sheet_system.add_segments([upper_span, lower_span, sheet])

begin
  sheet_system.solve(300, 3) do |iteration, stable|
    bitter_end.apply_force(Vector2.new("-10 lbf", "0 lbf"))
    upper_positions << upper_block.position
    lower_positions << lower_block.position
    upper_tensions << upper_span.tension
    lower_tensions << lower_span.tension
    sheet_tensions << sheet.tension
  end
rescue RuntimeError => error
  puts "Simulation failed! #{error.message}".red
end

ap(sheet_system.points)
ap(sheet_system.segments)
min_distance = (lower_block.position - batten0.position).magnitude / span_length
puts "Min distance: #{min_distance} (#{min_distance + 0.25})"

def map_to(collection, units = nil, &block)
  collection.map do |item|
    item = yield(item) if block_given?
    item = Unit.new(item)
    item = item.to(units) if units
    item.scalar
  end
end

[
  map_to(upper_positions, "in") { |p| p.x },
  map_to(upper_positions, "in") { |p| p.y },
  map_to(lower_positions, "in") { |p| p.x },
  map_to(lower_positions, "in") { |p| p.y },
  map_to(1..upper_tensions.size),
  map_to(upper_tensions, "lbf"),
  map_to(lower_tensions, "lbf"),
  map_to(sheet_tensions, "lbf"),
].each do |data|
  puts data.join(",")
end
