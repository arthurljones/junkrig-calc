module JunkSail
  class Sail
    BATTEN_STAGGER = 0.01
    BATTEN_TO_HEAD_PANEL_LUFF = 9/(25*12)
    BATTEN_TO_MAST_OFFSET = 0.05

    attr_reader :parallelogram_luff, :batten_length, :lower_panel_count, :head_panel_count, :yard_angle, :min_sheet_ratio, :sheet_area_width

    def self.cached_constant(method)
      define_method("#{method}_with_cache") { (@_constant_cache ||= {})[method] ||= send("#{method}_without_cache") }
      alias_method_chain(method, :cache)
    end

    def clear_cache
      @_constant_cache = nil
    end

    def initialize(parallelogram_luff:, batten_length:, lower_panel_count:, head_panel_count:, yard_angle:, min_sheet_ratio:, sheet_area_width:)
      @parallelogram_luff = parallelogram_luff
      @batten_length = batten_length
      @lower_panel_count = lower_panel_count
      @head_panel_count = head_panel_count
      @yard_angle = yard_angle
      @min_sheet_ratio = min_sheet_ratio
      @sheet_area_width = sheet_area_width
    end

    cached_constant def total_panels
      lower_panel_count + head_panel_count
    end

    cached_constant def panel_luff
      parallelogram_luff / lower_panel_count
    end

    cached_constant def panel_leech
      panel_luff
    end

    cached_constant def panel_width
      Helpers.triangle_height(batten_length, batten_length * (1.0 - BATTEN_STAGGER), panel_luff)
    end

    cached_constant def tack_angle
      Unit(Math::PI/2 - Math::asin(panel_width / batten_length), "radians")
    end

    cached_constant def clew_rise
      batten_length * Math::sin(tack_angle)
    end

    cached_constant def head_panel_luff
      (batten_length * BATTEN_TO_HEAD_PANEL_LUFF).to("in").round(0).to("ft")
    end

    cached_constant def tack
      Vector2.from_angle(tack_angle, batten_length)
    end

    cached_constant def clew
      Vector2.new(panel_width, clew_rise)
    end

    cached_constant def yard_span
      Vector2.from_angle(yard_angle, batten_length)
    end

    cached_constant def throat
      Vector2.new(Unit("0 ft"), parallelogram_luff + head_panel_luff * head_panel_count)
    end

    cached_constant def peak
      throat + yard_span
    end

    cached_constant def sling_point
      throat + yard_span / 2
    end

    cached_constant def sling_point_mast_distance
      batten_length * BATTEN_TO_MAST_OFFSET
    end

    cached_constant def image_bounds
      Bounds.from_points([tack, clew, throat, peak])
    end

    cached_constant def inner_sheet_distance
      min_sheet_ratio * panel_leech
    end

    cached_constant def outer_sheet_distance
      inner_sheet_distance + sheet_area_width
    end

    cached_constant def battens

      lower = (0 ... lower_panel_count + 1).collect { |position|
        Batten.new(batten_length, panel_luff * position, tack_angle)
      }
      upper = (1 ... head_panel_count + 1).collect { |position|
        Batten.new(batten_length, head_batten_luff_position(position), head_batten_angle(position))
      }

      lower + upper
    end

    cached_constant def panels
      battens.each_cons(2).collect { |b1, b2| Panel.new(b1, b2) }
    end

    cached_constant def area
      panels.each { |panel| ap "Panel area: #{panel.area}" }
      panels.sum(&:area)
    end

    cached_constant def center
      panels.sum { |panel| panel.center * panel.area } / area
    end

    def draw(svg)
      svg.layer("Sail") do |outer_layer|
        draw_sail(outer_layer)
        draw_sheet_zone(outer_layer)
        #sail.draw_measurements(outer_layer)
      end
    end

  private

    def head_batten_angle(position)
      tack_angle + ((yard_angle - tack_angle) / head_panel_count) * position
    end

    def head_batten_luff_position(position)
      parallelogram_luff + head_panel_luff * position
    end

    def draw_sail(group)
      square_ft = area.to("ft^2").round(0).scalar
      ap "Sail Area: #{square_ft}"

      group.layer("Panels") { |l| panels.each { |panel| l.line_loop(panel.perimeter) } }
      group.layer("Mast Distance") { |l| l.circle(sling_point, sling_point_mast_distance) }
      group.layer("Sling Point") { |l| l.circle(sling_point, Unit(3, "in")) }
      group.layer("Center of Effort") { |l| l.circle(center, Unit(3, "in")) }
      group.layer("Area") { |l| l.text(center + Vector2.new(0, -12), "#{square_ft} ft²") }
    end

    def draw_sheet_zone(group)
      pi = Unit(Math::PI, "rad")

      #Assumptions
      leech_angle = Unit(270, "deg")

      start = pi - tack_angle + Unit(30, "deg")
      stop = leech_angle - Unit(10, "deg")

      d_min = inner_sheet_distance
      d_outer = outer_sheet_distance

      top = Vector2.from_angle(start)
      bot = Vector2.from_angle(stop)

      arc1 = [top * d_min, bot * d_min]
      arc2 = [bot * d_outer, top * d_outer]

      group.layer("Sheet Zone") do |layer|
        layer.local_transform = Transform.new.translated(tack).scaled(Vector2.new(-1, 1))
        layer.build_path(:style => { :fill => "#000000", :fill_opacity => 0.1 }) do |path|
          path.move(arc1[0])
          path.arc(arc1[1], d_min, 0, false, false)
          path.line(arc2[0])
          path.arc(arc2[1], d_outer, 0, false, true)
        end
      end
    end

    def draw_measurements(svg)
      color = 0xFF2222AA

      def draw_length_line(p1, p2, ratio = 0.5, offset = Vector2.new(0, 0))
        delta = p2 - p1
        distance = delta.mag
        lines_context.draw_line(p1, p2, color, 2)
        numbers_context.draw_text(p1 + (delta * ratio) + offset, inches_and_eighths(distance), color)
      end

      b0 = battens[0]
      b1 = battens[@lower_panel_count]
      b3 = battens[-1]

      numbers_context.draw_line(b0.clew, b0.tack, color, 2) #For alignment

      draw_length_line(b0.clew, b0.tack, 0.5, Vector2.new(0, 1))
      draw_length_line(b1.clew, b1.tack, 0.5, Vector2.new(0, -0.5))

      draw_length_line(b1.clew, b3.tack, 0.5, Vector2.new(0, 1))
      draw_length_line(b1.tack, b3.tack, 0.5, Vector2.new(-0.1, 0.5))

      draw_length_line(b0.clew, b1.tack, 0.25)
      draw_length_line(b0.tack, b1.clew, 0.75, Vector2.new(0, 1))

      draw_length_line(b0.tack, b1.tack, 0.5, Vector2.new(1.5, 0))
      draw_length_line(b0.clew, b1.clew)

      battens[lower_panel_count + 1 ... battens.size].each do |b2|
        draw_length_line(b1.clew, b2.clew)
        draw_length_line(b1.tack, b2.clew)
      end

      lines_image.save(lines_filename, :dpi=>[pixels_per_inch, pixels_per_inch])
      numbers_image.save(numbers_filename, :dpi=>[pixels_per_inch, pixels_per_inch])
    end
  end
end