require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"

fixed = Sheet::AnchorPoint.new(position: ["1 in", "0 in"])
free = Sheet::FreePoint.new(position: ["0 in", "0 in"])

line = Sheet::Segment.new(length: "20 in", points: [fixed, free, fixed, free, fixed])

def iterate(points, lines, max_iterations, max_stable_iterations)
  stable_iterations = 0

  (1..max_iterations).each do |iteration|
    yield(iteration, stable_iterations) if block_given?

    lines.each(&:apply)
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

iterate([fixed, free], [line], 200, 3) do |iteration, stable|
  free.apply_force(Vector2.new("0 lbf", "-40 lbf"))
  ap iteration: iteration, stable: stable, position: free.position, tension: line.tension, force: free.force
end

elongation_at_break = 0.167 #Elongation to breaking stress
tensile_strength = Unit.new("2650 lbf")
modulus_of_elasticity = Unit.new("2 GPa")
rope_diameter = Unit.new(3/8, "in")
solid = Math::PI * (rope_diameter / 2) ** 2
strand_radius = rope_diameter / (2 * 2.154) #Circle packing ratio from https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
theoretical = 3 * Math::PI * strand_radius ** 2

cross_section = (tensile_strength / (elongation_at_break * modulus_of_elasticity)).to("in^2")
puts area: cross_section, solid: solid, theoretical: theoretical, ratio: cross_section/solid
