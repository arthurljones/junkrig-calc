require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"

fixed = Sheet::AnchorPoint.new(position: ["1 in", "0 in"])
free = Sheet::FreePoint.new(position: ["0 in", "0 in"])

line = Sheet::Segment.new(length: "20 in", points: [fixed, free, fixed, free, fixed])

points = [fixed, free]
max_stable_iterations = 3

stable_iterations = 0
(1..20).each do |iter|
  line.apply

  free.apply_force(Vector2.new("0 lbf", "-40 lbf"))

  ap iteration: iter, stable: stable_iterations, position: free.position, tension: line.tension, force: free.force

  stable = true
  points.each do |point|
    stable = false unless point.resolve
  end

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
