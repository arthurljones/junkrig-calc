require_relative "boilerplate"
require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"

fixed = Sheet::AnchorPoint.new(position: ["5 in", "0 in"])
block = Sheet::FreePoint.new(position: ["0 in", "0 in"])
free = Sheet::FreePoint.new(position: ["0 in", "0.1 in"])

line = Sheet::Segment.new(length: "20 in", points: [fixed, block, free, block, free])

(1..20).each do |iter|
  line.apply

  free.apply_force(Vector2.new("0 lbf", "-10 lbf"))

  ap position: free.position, tension: line.tension, force: free.force

  fixed.resolve
  free.resolve

end
