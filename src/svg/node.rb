require "nokogiri"
require_relative "path_builder"

module SVG
  class Node
    VALID_TRANSFORMS = %w(translate scale rotate skewX skewY matrix).freeze
    LOCAL_TRANSFORM_ATTRIBUTE = "junkrig:local_transform"

    attr_reader :node

    def self.new_document(options = {})
      document = new(Nokogiri::XML::Document.new)

      options = options.merge(
        "xmlns" => "http://www.w3.org/2000/svg",
        "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape",
        "xmlns:junkrig" => "http://www.github.com/arthurljones/junkrig-calc")

      document.child(:svg, options)
    end

    def initialize(node)
      @node = node
    end

    def local_transform
      decode_transform(node[LOCAL_TRANSFORM_ATTRIBUTE])
    end

    def local_transform=(transform)
      node[LOCAL_TRANSFORM_ATTRIBUTE] = transform.to_xml
    end

    def absolute_transform
      node_path = node.ancestors.reverse.to_a + [node]
      node_path.reduce(Transform.new) do |memo, ancestor|
        local_transform = decode_transform(ancestor[LOCAL_TRANSFORM_ATTRIBUTE])
        local_transform ? memo * local_transform : memo
      end
    end

    def path(commands, options = {})
      options[:d] = commands
      child(:path, options)
    end

    def build_path(options = {}, &block)
      PathBuilder.new(self, options, &block)
    end

    def line_loop(points, options = {})
      build_path do |path|
        path.move(points.pop)
        points.each { |point| path.line(point) }
      end
    end

    def circle(center, radius, options = {})
      center = (absolute_transform * center).to("in").unitless
      options = options.merge(
        :cx => center.x,
        :cy => center.y,
        :r => radius.to("in").scalar,
      )

      child(:circle, options)
    end

    def text(anchor, value, options = {})
      options[:style] ||= {
        :font_family => "Courier",
        :fill => "#000000",
        :font_size => 10,
      }
      anchor = (absolute_transform * anchor).to("in").unitless
      options[:x] = anchor.x
      options[:y] = anchor.y

      child(:text, value, options)
    end

    def group(options = {}, &block)
      options[:style] ||= {
        :fill => :none,
        :stroke => "#000000",
        :stroke_width => 0.25,
        :display => :inline
      }

      result = child(:g, options)
      yield result if block_given?
      result
    end

    def layer(label = "Layer", options = {}, &block)
      options["inkscape:label"] = label
      options["inkscape:groupmode"] = "layer"
      group(options, &block)
    end

    def child(name, *args, &block)
      options = args.extract_options!
      element = node.document.create_element(name.to_s, *(args + [clean_options(options)]), &block)
      node.add_child(element)
      Node.new(element)
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

    def decode_transform(str)
      return nil unless str.present?
      Transform.from_xml(str)
    end
  end
end
