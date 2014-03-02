require 'rubygems'
require 'bundler/setup'

require "awesome_print"
require "active_support/all"
require "nokogiri"
require "matrix"

require_relative "src/vector2"
require_relative "src/bounds"
require_relative "src/svg"
require_relative "src/helpers"

require_relative "src/batten"
require_relative "src/panel"
require_relative "src/sail"

sail = Sail.new(168, 240, 4, 3, Math::PI * 70 / 180)
bounds = sail.bounds
width = bounds.size.x
height = bounds.size.y
img = SVG.new_document#(:width => "#{width}in", :height => "#{height}in", :viewBox => "0 0 #{width} #{height}")
outer_group = img.group(:transform => { :rotate => 180, :translate => -bounds.max })
sail.draw_sail(outer_group)
#sail.draw_measurements(img)
#sail.draw_sheet_zone(2, img)

File.open("test.svg", "wb") do |file|
  file.write(img.node.to_xml)
  file.close
end