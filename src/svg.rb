class SVG
  attr_reader :node

  VALID_TRANSFORMS = %w(translate scale rotate skewX skewY matrix).freeze

  def initialize(node)
    @node = node
  end

  def self.new_document(options = {})
    document = new(Nokogiri::XML::Document.new)

    options = options.merge(
      "xmlns" => "http://www.w3.org/2000/svg",
      "xmlns:svg" => "http://www.w3.org/2000/svg",
      "xmlns:sodipodi" => "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
      "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape")

    document.child(:svg, options)
  end

  def lines(points, options = {})
    options = options.dup
    points = points.clone
    start = points.shift

    options[:d] = "M #{start} L #{points.join(" ")}"

    child(:path, options)
  end

  def arc(start, stop, options = {})
    options = options.dup
    radius = options.delete(:radius) || 1
    radius = Vector2.new(radius, radius) if Numeric === radius
    rotation = options.delete(:rotation) || 0
    large_arc = options.delete(:large_arc) || 1
    clockwise = options.delete(:clockwise) || 0
    options[:d] = "M #{start} A #{radius} #{rotation} #{large_arc ? 1 : 0} #{clockwise ? 1 : 0} #{stop}"
    child(:path, options)
  end

  def circle(center, options = {})
    options = options.dup
    start_angle = options.delete(:start_angle) || 0
    stop_angle = options.delete(:stop_angle) || 359
    radius = options.delete(:radius) || 1
    sweep = (stop_angle - start_angle).abs
    start = center + Vector2.from_angle(start_angle * Math::PI / 180, radius)
    stop = center + Vector2.from_angle(stop_angle * Math::PI / 180, radius)
    options[:radius] = radius
    options[:rotation] = 0
    options[:large_arc] = sweep > 180
    options[:clockwise] = stop_angle > start_angle
    options[:closed] = (sweep - 360).abs <= 0.001 if options[:closed].nil?
    arc(start, stop, options)
  end

  def group(options = {})
    options[:style] ||= {
      :fill => :none,
      :stroke => "#000000",
      :stroke_width => 0.25,
      :display => :inline
    }

    child(:g, options)
  end

  def layer(options = {})
    options["inkscape:label"] = options.delete(:label) || "Layer"
    options["inkscape:groupmode"] = "layer"
    group(options)
  end

  def child(name, options = {}, &block)
    element = @node.document.create_element(name.to_s, clean_options(options), &block)
    @node.add_child(element)
    SVG.new(element)
  end

private

  def clean_options(options)
    options = options.dup

    style = options[:style]
    if Hash === style
      options[:style] = style.collect { |key, val|"#{key.to_s.dasherize}:#{val}" }.join(";")
    end

    transform = options[:transform]
    if Hash === transform
      transforms = transform.map do |operation, value|
        raise "Invalid transform type #{operation}" unless VALID_TRANSFORMS.include?(operation.to_s)
        "#{operation}(#{value})"
      end
      options[:transform] = transforms.join(" ")
    end

    closed = options.delete(:closed)
    if closed != false && options[:d].present?
      options[:d] << " z"
    end

    options
  end

end