class Sail
  BATTEN_STAGGER = 0.01
  BATTEN_TO_HEAD_PANEL_LUFF = 0.03
  BATTEN_TO_MAST_OFFSET = 0.05

  attr_reader :parallelogram_luff, :batten_length, :lower_panel_count, :head_panel_count, :yard_angle

  def self.cached_constant(method)
    define_method("#{method}_with_cache") { (@_constant_cache ||= {})[method] ||= send("#{method}_without_cache") }
    alias_method_chain(method, :cache)
  end

  def clear_cache
    @_constant_cache = nil
  end

  def initialize(luff, batten_length, lower_panels, head_panels, yard_angle)
    @parallelogram_luff = luff
    @batten_length = batten_length
    @lower_panel_count = lower_panels
    @head_panel_count = head_panels
    @yard_angle = yard_angle
  end

  cached_constant def total_panels
    lower_panel_count + head_panel_count
  end

  cached_constant def panel_luff
    parallelogram_luff / lower_panel_count
  end

  cached_constant def panel_width
    Helpers.triangle_height(batten_length, batten_length * (1.0 - BATTEN_STAGGER), panel_luff)
  end

  cached_constant def tack_angle
    Math::PI/2 - Math::asin(panel_width / batten_length)
  end

  cached_constant def clew_rise
    batten_length * Math::sin(tack_angle)
  end

  cached_constant def head_panel_luff
    (batten_length * BATTEN_TO_HEAD_PANEL_LUFF).round
  end

  cached_constant def tack
    Vector2.new
  end

  cached_constant def clew
    Vector2.new(panel_width, clew_rise)
  end

  cached_constant def yard_span
    Vector2.from_angle(yard_angle, batten_length)
  end

  cached_constant def throat
    Vector2.new(0, parallelogram_luff + head_panel_luff * head_panel_count)
  end

  cached_constant def peak
    throat + yard_span
  end

  cached_constant def sling_point
    throat + yard_span / 2
  end

  cached_constant def mast_from_tack
    sling_point.x - batten_length * BATTEN_TO_MAST_OFFSET
  end

  cached_constant def bounds
    Bounds.from_points([tack, clew, throat, peak])
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
    panels.sum(&:area)
  end

  cached_constant def center
    panels.sum { |panel| panel.center * panel.area } / area
  end

  def draw_sail(svg)
    sq_feet = (area / 144).round(0)
    mast_center = Vector2.new(mast_from_tack, sling_point.y)
    offset = Vector2.new(0, 12)

    svg.layer("Sail") do |outer|
      outer.layer("Panels") { |l| panels.each { |panel| l.line_loop(panel.perimeter) } }
      outer.layer("Mast Centerline") { |l| l.line_loop([mast_center - offset, mast_center + offset], :closed => false) }
      outer.layer("Sling Point") { |l| l.circle(sling_point, 3) }
      outer.layer("Center of Effort") { |l| l.circle(center, 3) }
      outer.layer("Center of Effort") { |l| l.text(center + Vector2.new(0, -12), "#{sq_feet} ft²") }
    end
  end

  def draw_sheet_zone(d_min_ratio, svg)
    #Assumptions
    leech_angle = 3*Math::PI/2
    panel_leech = panel_luff

    start = pi - tack_angle + radians(30)
    stop = leech_angle - radians(10)

    d_min = d_min_ratio * panel_leech
    d_outer = (d_min_ratio + 1.5) * panel_leech

    top = Vector2.from_angle(start)
    bot = Vector2.from_angle(stop)

    top_points = [top * d_min, top * d_outer]
    bot_points = [bot * d_min, bot * d_outer]

    color = 0xFF000000
    context.draw_arc(Vector2.new(0, 0), d_min, color, start, stop)
    context.draw_arc(Vector2.new(0, 0), d_outer, color, start, stop)
    context.draw_line(top_points[0], top_points[1], color)
    context.draw_line(bot_points[0], bot_points[1], color)
    context.draw_point(Vector2.new(0, 0), color, 3)

    result = image.transpose(Image.FLIP_TOP_BOTTOM)
    result.save(filename, :dpi=>[pixels_per_inch, pixels_per_inch])
  end


  def draw_measurements(svg)
    pixels_per_foot = pixels_per_inch * 12
    margin = 100
    size = (bounds.scaled(pixels_per_foot).size + Vector2.new(margin * 2, margin * 2)).tup_int
    translation = [size[0] - margin, size[1] - margin, 0]
    rotation = radians(180)
    scale = pixels_per_foot

    lines_image = Image.new("RGBA", size, 0xFFFFFFFF)
    lines_context = DrawContext(lines_image)
    lines_context.matrix = lines_context.matrix.translated(translation).rotated(rotation).scaled(scale)

    numbers_image = Image.new("RGBA", size, 0xFFFFFFFF)
    numbers_context = DrawContext(numbers_image)
    numbers_context.matrix = numbers_context.matrix.translated(translation).rotated(rotation).scaled(scale)

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

private
  def head_batten_angle(position)
    tack_angle + ((yard_angle - tack_angle) / head_panel_count) * position
  end

  def head_batten_luff_position(position)
    parallelogram_luff + head_panel_luff * position
  end

end