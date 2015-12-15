require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"

#TODO: Move all points proportionally to their amount of force and to the over-length of the line constraints.
# The concept is that points should never move so far as to release all the tension on a line.
# This requires a separate accounting of force and motion

def iterate(points, lines, max_iterations, max_stable_iterations)
  stable_iterations = 0

  (1..max_iterations).each do |iteration|
    lines.each(&:apply)

    yield(iteration, stable_iterations) if block_given?

    stable = points.map(&:resolve).none?

    if stable
      stable_iterations += 1
      if stable_iterations >= max_stable_iterations
        puts "Done after #{stable_iterations} stable iterations"
        break
      end
    else
      stable_iterations = 0
    end
  end
end

span_length = Unit.new("10 in")
clew_height = Unit.new("50 in")

anchor = Sheet::AnchorPoint.new(name: "anchor", position: ["0 in", "0 in"])
batten0 = Sheet::AnchorPoint.new(name: "batten0", position: ["0 in", clew_height])
batten1 = Sheet::AnchorPoint.new(name: "batten1", position: ["0 in", clew_height])
upper_block = Sheet::FreePoint.new(name: "upper_block", position: ["1 in", clew_height])
lower_block = Sheet::FreePoint.new(name: "lower_block", position: ["2 in", clew_height])
bitter_end = Sheet::FreePoint.new(name: "bitter_end", position: ["0 in", "-5 in"])

upper_span = Sheet::Segment.new(name: "upper_span", length: span_length, points: [batten1, upper_block])
lower_span = Sheet::Segment.new(name: "lower_span", length: span_length * 2, points: [batten0, lower_block, upper_block, lower_block])
sheet = Sheet::Segment.new(name: "sheet", length: clew_height + span_length, points: [lower_block, anchor, bitter_end])

points = [anchor, batten0, batten1, upper_block, lower_block, bitter_end]
lines = [upper_span, lower_span, sheet]

positions = []
upper_tensions = []
lower_tensions = []
sheet_tensions = []

iterate(points, lines, 40, 3) do |iteration, stable|
  bitter_end.apply_force(Vector2.new("-50 lbf", "0 lbf"))
  positions << lower_block.position
  ap({
    iteration: iteration,
    stable: stable,
    lower_block_position: lower_block.position,
    lower_block_force: lower_block.force,
    tensions: lines.each_with_object({}) { |line, result| result[line.name] = line.tension }
  })
  upper_tensions << upper_span.tension
  lower_tensions << lower_span.tension
  sheet_tensions << sheet.tension
end

ap({
  anchor: anchor,
  batten0: batten0,
  batten1: batten1,
  block: lower_block,
  bitter_end: bitter_end,
  min_distance: (lower_block.position - batten0.position).magnitude / span_length
})

puts positions.map{|p| p.x.to("in").scalar}.join(",")
puts positions.map{|p| p.y.to("in").scalar}.join(",")
puts upper_tensions.map{|p| p.to("lbf").scalar}.join(",")
puts lower_tensions.map{|p| p.to("lbf").scalar}.join(",")
puts sheet_tensions.map{|p| p.to("lbf").scalar}.join(",")

elongation_at_break = 0.167 #Elongation to breaking stress
tensile_strength = Unit.new("2650 lbf")
modulus_of_elasticity = Unit.new("2 GPa")
rope_diameter = Unit.new(3/8, "in")
solid = Math::PI * (rope_diameter / 2) ** 2
strand_radius = rope_diameter / (2 * 2.154) #Circle packing ratio from https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
theoretical = 3 * Math::PI * strand_radius ** 2

cross_section = (tensile_strength / (elongation_at_break * modulus_of_elasticity)).to("in^2")
puts area: cross_section, solid: solid, theoretical: theoretical, ratio: cross_section/solid
