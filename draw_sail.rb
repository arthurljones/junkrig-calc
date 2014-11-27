require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("src/**/*.rb").each { |file| require_relative file }

sail = JunkSail::Sail.new(
  parallelogram_luff: Unit(16, "ft"),
  batten_length: Unit(18, "ft"),
  lower_panel_count: 4,
  head_panel_count: 3,
  yard_angle: Unit(65, "deg"),
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

draw_sail
