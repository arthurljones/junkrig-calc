require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"


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


anchor = Sheet::AnchorPoint.new(position: ["0 in", "0 in"])
batten0 = Sheet::AnchorPoint.new(position: ["0 in", "20 in"])
batten1 = Sheet::AnchorPoint.new(position: ["0 in", "20 in"])
block = Sheet::FreePoint.new(position: ["5 in", "15 in"])
bitter_end = Sheet::FreePoint.new(position: ["0 in", "-5 in"])

span = Sheet::Segment.new(length: span_length * 2, points: [batten0, block, batten1])
sheet = Sheet::Segment.new(length: span_length * 5, points: [block, anchor, bitter_end])

points = [anchor, batten0, batten1, block, bitter_end]
lines = [span, sheet]

positions = []

iterate(points, lines, 100, 3) do |iteration, stable|
  bitter_end.apply_force(Vector2.new("-50 lbf", "0 lbf"))
  positions << block.position
  ap({
    iteration: iteration,
    stable: stable,
    position: block.position,
    sheet_tension: sheet.tension,
    span_tension: span.tension,
    force: block.force
  })
end

ap({
  anchor: anchor,
  batten0: batten0,
  batten1: batten1,
  block: block,
  bitter_end: bitter_end,
  min_distance: (block.position - batten0.position).magnitude / span_length
})

puts positions.map{|p| p.x.to("in").scalar}.join(",")
puts positions.map{|p| p.y.to("in").scalar}.join(",")

elongation_at_break = 0.167 #Elongation to breaking stress
tensile_strength = Unit.new("2650 lbf")
modulus_of_elasticity = Unit.new("2 GPa")
rope_diameter = Unit.new(3/8, "in")
solid = Math::PI * (rope_diameter / 2) ** 2
strand_radius = rope_diameter / (2 * 2.154) #Circle packing ratio from https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
theoretical = 3 * Math::PI * strand_radius ** 2

cross_section = (tensile_strength / (elongation_at_break * modulus_of_elasticity)).to("in^2")
puts area: cross_section, solid: solid, theoretical: theoretical, ratio: cross_section/solid
