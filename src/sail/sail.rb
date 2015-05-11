require "options_initializer"
require_relative "svg_drawable"

require "math/vector2"
require "math/helpers"
require "sail/batten"
require "sail/panel"

module Sail
  class Sail
    include OptionsInitializer
    include SVGDrawable

    BATTEN_STAGGER = 0.01
    BATTEN_TO_HEAD_PANEL_LUFF = 9/(25*12)
    BATTEN_TO_MAST_OFFSET = 0.05

    attr_reader *%i(
      total_panels
      panel_luff
      panel_leech
      panel_width
      tack_angle
      clew_rise
      head_panel_luff
      tack
      clew
      yard_span
      throat
      peak
      sling_point
      sling_point_mast_distance
      inner_sheet_distance
      outer_sheet_distance
      battens
      panels
      area
      center
    )

    options_initialize(
      parallelogram_luff: { units: "in" },
      batten_length: { units: "in" },
      lower_panel_count: { },
      head_panel_count: { },
      yard_angle: { units: "degrees" },
      min_sheet_ratio: { },
      sheet_area_width: { units: "in" },
    ) do |options|

      @total_panels = @lower_panel_count + @head_panel_count
      @panel_luff = @parallelogram_luff / @lower_panel_count
      @panel_leech = @panel_luff

      @panel_width = MathHelpers.triangle_height(@batten_length, @batten_length * (1.0 - BATTEN_STAGGER), @panel_luff)
      @tack_angle = Unit(Math::PI/2 - Math::asin(@panel_width / @batten_length), "radians")
      @clew_rise = @batten_length * Math::sin(@tack_angle)
      @head_panel_luff = (@batten_length * BATTEN_TO_HEAD_PANEL_LUFF).to("in").round(0).to("ft")

      @tack = Vector2.from_angle(@tack_angle, @batten_length)
      @clew = Vector2.new(@panel_width, @clew_rise)
      @yard_span = Vector2.from_angle(@yard_angle, @batten_length)
      @throat = Vector2.new(Unit("0 ft"), @parallelogram_luff + @head_panel_luff * @head_panel_count)
      @peak = @throat + @yard_span
      @sling_point = @throat + @yard_span / 2

      @sling_point_mast_distance = @batten_length * BATTEN_TO_MAST_OFFSET
      @inner_sheet_distance = @min_sheet_ratio * @panel_leech
      @outer_sheet_distance = @inner_sheet_distance + @sheet_area_width

      lower_battens = (0 ... @lower_panel_count + 1).collect do |position|
        Batten.new(@batten_length, @panel_luff * position, @tack_angle)
      end

      upper_battens = (1 ... @head_panel_count + 1).collect do |position|
        luff_position = @parallelogram_luff + @head_panel_luff * position
        angle = @tack_angle + ((@yard_angle - @tack_angle) / @head_panel_count) * position
        Batten.new(@batten_length, luff_position, angle)
      end

      @battens = lower_battens + upper_battens
      @panels = @battens.each_cons(2).collect { |b1, b2| Panel.new(b1, b2) }

      @area = @panels.sum(&:area)
      @center = @panels.sum { |panel| panel.center * panel.area } / @area
    end
  end
end
