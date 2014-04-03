require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("src/**/*.rb").each { |file| require_relative file }

start = Time.now

def draw_sail
  sail = JunkSail::Sail.new(
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

  #stop = Time.now
  #puts "Rendered first in #{((stop - start) * 1000).round(2)}ms"
end

def calculate_mast_pieces
  piece_lengths = [
    #48,
    54, 54, 56, 57, 57, 57, 57, 58, 58, 58, 58, 59, 59,
    60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 62, 62, 62, 62, 63, 64, 65, 66, 66, 67, 67, 67, 67, 67, 68, 68, 68, 69, 69,
    70, 71, 71, 72, 75, 75, 75, 75, 75, 76, 76, 79, 79, 79, 79, 79,
    80, 81, 81, 81, 82, 82, 83, 83, 83, 84, 85, 86, 86, 87, 87, 88, 88, 88, 89, 89, 89, 89, 89,
    91, 93, 95, 95, 95, 96, 96, 96, 96, 97, 97, 97, 98, 99, 99, 99,
    100, 100, 101, 101, 113, 115, 116, 118, 119, 120, 136, 137, 138, 141, 142, 155, 157, 157, 160, 161, 178,
    241,
    53, 54, 54, 55, 58, 63, 65, 65, 65, 68,
    71, 78, 85, 86, 87, 93, 96, 97, 100, 103, 106
  ]


  double_scarfed_lengths = [
    50, 51, 54, 55, 56, 57, 58, 59, 59, 59, 59,
    61, 61, 62, 64, 64, 64, 64, 64, 65, 65, 65, 68, 69, 69,
    71, 72, 74, 74, 74, 75, 76, 76, 77, 77, 78, 79, 79, 89, 89, 91, 96,
    112, 115, 117,
    56,	60,	64,
    81,	87
  ]
  
  piece_lengths.sort!
  stave_lengths = [245] * 9 + [96] * 30 + [397] * 4 #[240] * 28 #397

  builder = Mast::StaveBuilder.new(stave_lengths, piece_lengths, double_scarfed_lengths, 70, 4)
  builder.print_data
end

calculate_mast_pieces
#draw_sail