require_relative "boilerplate"

require "junk_sail/sail"

sail = JunkSail::Sail.new(
  parallelogram_luff: Unit(16, "ft"),
  batten_length: Unit(18, "ft"),
  lower_panel_count: 4,
  head_panel_count: 3,
  yard_angle: Unit(65, "deg"),
  min_sheet_ratio: 2.0,
  sheet_area_width: Unit(4, "ft"),
)

sail.draw_to_file(ARGV[0] || "sail.svg")
