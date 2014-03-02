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

img = SVG.new_document#Rasem::SVGImage.new(100, 100)
sail = Sail.new(14*12, 20*12, 4, 3, Math::PI * 70 / 180)
sail.draw_sail(img)
#sail.draw_measurements(img)
#sail.draw_sheet_zone(2, img)

File.open("test.svg", "wb") do |file|
  file.write(img.node.to_xml)
  file.close
end