require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("src/**/*.rb").each { |file| require_relative file }


def draw_sail
  sail = JunkSail::Sail.new(
    parallelogram_luff: Unit(14, "ft"),
    batten_length: Unit(20, "ft"),
    lower_panel_count: 4,
    head_panel_count: 3,
    yard_angle: Unit(60, "deg"),
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
end

class Array
  def subtract!(other)
    other.select do |elem|
      index = index(elem)
      delete_at(index) if index
      index
    end
  end
end

def calculate_mast_pieces
  all_singles = [
    59, 69, 72, 75, 79, 79, 87, 87, 88, 89, 89,
    91, 93, 95, 95, 95, 96, 96, 96, 96, 97, 97, 97, 97, 98, 99, 99,
    100, 100, 100, 100, 101, 103, 106, 113, 115, 116, 119, 120,
    136, 137, 138, 141, 142, 155, 157, 157, 160, 161, 178, 241
  ]

  all_doubles = [
    48, 50, 51, 53, 54, 54, 54, 54, 54, 55, 55, 56, 56, 56, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58,
    60, 60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62, 63, 63, 64, 64, 64, 64, 64, 64, 64,
    65, 65, 65, 65, 65, 65, 65, 66, 66, 67, 67, 67, 67, 67, 68, 68, 68, 68, 68,
    70, 71, 71, 71, 71, 74, 74, 74, 76, 76, 76, 76, 77, 77, 78, 78,
    80, 81, 81, 81, 81, 82, 82, 83, 83, 83, 85, 58, 68, 86, 86, 112, 117, 118
  ]

  available_singles = [
    56, 63
  ]

  available_doubles = [
    115, 89, 85, 72, 64, 64, 59
  ]

  mast_stave_length = 419 #28
  yard_stave_length = 245 #8

  extra_stave_length = 4

  stave_options = {
    :A => { :length => mast_stave_length, :single => [241], :double => [67, 61, 56] },
    :L => { :length => mast_stave_length, :single => [136, 95], :double => [82, 83, 55]},
    :N => { :length => mast_stave_length, :single => [119, 96], :double => [71, 65, 54, 54]},
    :X => { :length => mast_stave_length, :single => [97, 75], :double => [76, 64, 54]},

    :AA => { :length => mast_stave_length, :double => [89, 59, 88, 96, 75] },
    :CC => { :length => mast_stave_length, :single => [93, 76], :double => [96, 79, 79]},
  }

  staves = stave_options.map do |name, opts|
    singles = Mast::LumberPiece.init_many(opts[:single] || [], false)
    doubles = Mast::LumberPiece.init_many(opts[:double] || [], true)
    pieces = singles + doubles
    pieces.each(&:lock)
    Mast::Stave.new(pieces, opts[:length] + extra_stave_length, name)
  end

  puts staves

  builder = Mast::StaveBuilder.new(staves, available_singles, available_doubles, 70)
  builder.print_data
end

calculate_mast_pieces
#draw_sail
