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

    attr_reader *%i(
      total_panels
      lower_panel_luff
      panel_leech
      parallelogram_width
      tack_angle
      clew_rise
      head_panel_luff
      total_luff
      total_leech
      tack
      clew
      yard
      throat
      peak
      tack_to_peak
      aspect_ratio
      sling_point
      sling_point_to_mast_center
      inner_sheet_distance
      outer_sheet_distance
      battens
      panels
      area
      center
      circumference
      tack_to_mast_center
      clew_to_mast_center
      sail_balance_forward_of_mast
    )

    options_initialize(
      parallelogram_luff: { units: "in" },
      batten_length: { units: "in" },
      lower_panel_count: { },
      head_panel_count: { },
      yard_angle: { units: "degrees" },
      min_sheet_ratio: { },
      sheet_area_width: { units: "in" },
      head_panel_luff_to_batten_ratio: { default: 9/(25*12) },
      upper_luff_curve_balance: { default: 0 }, #0.0 results in a vertical luff, 1.0 results in matching curve to leech
      sling_offset_to_batten_length: { default: 0.05 },
    ) do |options|

      @total_panels = @lower_panel_count + @head_panel_count
      @lower_panel_luff = @parallelogram_luff / @lower_panel_count
      @panel_leech = @lower_panel_luff

      @parallelogram_width = MathHelpers.triangle_height(@batten_length, @batten_length * (1.0 - BATTEN_STAGGER), @lower_panel_luff) #AKA chord
      @tack_angle = Unit.new(Math::PI/2 - Math::asin(@parallelogram_width / @batten_length), "radians")
      @clew_rise = @batten_length * Math::sin(@tack_angle)
      @head_panel_luff = (@batten_length * @head_panel_luff_to_batten_ratio).to("in").round(0).to("ft")
      @total_luff = @parallelogram_luff + @head_panel_luff * @head_panel_count

      @tack = Vector2.new("0 ft", "0 ft")
      @clew = Vector2.new(@parallelogram_width, @clew_rise)

      @sling_point_to_mast_center = @batten_length * @sling_offset_to_batten_length
      @inner_sheet_distance = @min_sheet_ratio * @panel_leech
      @outer_sheet_distance = @inner_sheet_distance + @sheet_area_width

      lower_battens = (0 ... @lower_panel_count + 1).collect do |position|
        Batten.new(@batten_length, Vector2.new("0 in", @lower_panel_luff * position), @tack_angle)
      end

      head_panel_angle_increment = (@yard_angle - @tack_angle) / @head_panel_count
      upper_battens = (1 ... @head_panel_count + 1).collect do |position|
        angle_offset = head_panel_angle_increment * position
        length_offset = Math::sin(angle_offset) * @upper_luff_curve_balance * @head_panel_luff
        luff_x = length_offset
        luff_y = @parallelogram_luff + @head_panel_luff * position
        batten_angle = @tack_angle + angle_offset
        batten_length = @batten_length - 2 * length_offset
        Batten.new(batten_length, Vector2.new(luff_x, luff_y), batten_angle)
      end

      @yard = upper_battens.last
      @throat = @yard.tack
      @peak = @yard.clew
      @sling_point = @throat + (@peak - @throat) / 2
      @tack_to_peak = @peak - @tack
      @aspect_ratio = (@tack_to_peak.y - @clew_rise / 2) / @parallelogram_width

      @battens = lower_battens + upper_battens
      @panels = @battens.each_cons(2).collect { |b1, b2| Panel.new(b1, b2) }

      @area = @panels.sum(&:area)
      @center = @panels.sum { |panel| panel.center * panel.area } / @area
      @total_leech = @panels.sum(&:leech_length)
      @circumference = @total_luff + @total_leech + @batten_length * 2

      @tack_to_mast_center = @sling_point.x - @sling_point_to_mast_center
      @clew_to_mast_center = @parallelogram_width - @tack_to_mast_center
      @sail_balance_forward_of_mast = @tack_to_mast_center / @parallelogram_width
    end

    def reefed_area(panels_reefed)
      @panels.drop(panels_reefed).sum(&:area)
    end

    def luff_to_batten_length
      @lower_panel_luff / @batten_length
    end

  end
end
