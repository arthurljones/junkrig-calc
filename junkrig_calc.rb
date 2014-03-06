require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("src/**/*.rb").each { |file| require_relative file }

start = Time.now

sail = Sail.new(
  parallelogram_luff: Unit(14, "ft"),
  batten_length: Unit(20, "ft"),
  lower_panel_count: 4,
  head_panel_count: 3,
  yard_angle: Unit(70, "deg"),
  min_sheet_ratio: 2.0,
  sheet_area_width: Unit(4, "ft"),
)

bounds = sail.image_bounds
image_size = bounds.size.to("in")
svg = SVG::Node.new_document(
  :width => image_size.x.to_s,
  :height => image_size.y.to_s,
  :viewBox => "0 0 #{image_size.x.scalar.round(4)} #{image_size.y.scalar.round(4)}"
)
transform = Transform.new.scaled(Vector2.new(-1, -1)).translated(-bounds.max)
svg.local_transform = transform
sail.draw(svg)

filename = ARGV[0] || "sail.svg"
File.open(filename, "wb") do |file|
  file.write(svg.node.to_xml)
  file.close
end

stop = Time.now

sail.draw(SVG::Node.new_document)

stop2 = Time.now

puts "Rendered first in #{((stop - start) * 1000).round(2)}ms"
puts "Rendered second in #{((stop2 - stop) * 1000).round(2)}ms"

