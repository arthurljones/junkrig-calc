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
    points = points.clone
    start = points.shift

    options[:d] = "M #{start} L #{points.join(" ")}"
    options[:d] << " z" unless options.delete(:closed) == false

    child(:path, options)
  end

  def group(options = {})

    options[:style] ||= {
      :fill => :none,
      :stroke => "#000000",
      :stroke_width => 1,
      :display => :inline
    }

    child(:g, options)
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

    options
  end

end