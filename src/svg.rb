class SVG
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def self.new_document
    document = new(Nokogiri::XML::Document.new)
    document.child(:svg,
      "xmlns" => "http://www.w3.org/2000/svg",
      "xmlns:osb" => "http://www.openswatchbook.org/uri/2009/osb",
      "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
      "xmlns:cc" => "http://creativecommons.org/ns#",
      "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "xmlns:svg" => "http://www.w3.org/2000/svg",
      "xmlns:xlink" => "http://www.w3.org/1999/xlink",
      "xmlns:sodipodi" => "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
      "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape"
    )
  end

  def lines(points, closed = true)
    points = points.clone
    start = points.shift
    child(:path, :style => "fill:none;stroke:#000000;stroke-width:1;display:inline", :d => "M #{start} L #{points.join(" ")} z")
  end

  def child(name, *args, &block)
    element = @node.document.create_element(name.to_s, *args, &block)
    @node.add_child(element)
    SVG.new(element)
  end

end