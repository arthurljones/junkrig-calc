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

    def local_transform=(value)
      node[LOCAL_TRANSFORM_ATTRIBUTE] = Base64.encode64(Marshal.dump(value))
    end

    def absolute_transform
      node_path = node.ancestors.reverse.to_a + [node]
      node_path.reduce(Transform.new) do |memo, ancestor|
        local_transform = decode_transform(ancestor[LOCAL_TRANSFORM_ATTRIBUTE])
        local_transform ? memo * local_transform : memo
      end
    end

    def lines(points, options = {})
      options = options.dup
      transform = absolute_transform
      points = points.map { |p| transform * p }
      start = points.shift

      options[:d] = "M #{start} L #{points.join(" ")}"

      child(:path, options)
    end

    def arc(start, stop, options = {})
      options = options.dup
      transform = absolute_transform
      start = transform * start
      stop = transform * stop
      radius = options.delete(:radius) || 1
      radius = Vector2.new(radius, radius) if Numeric === radius
      rotation = options.delete(:rotation) || 0
      large_arc = options.delete(:large_arc) || 1
      clockwise = options.delete(:clockwise) || 0

      options[:d] = "M #{start} A #{radius} #{rotation} #{large_arc ? 1 : 0} #{clockwise ? 1 : 0} #{stop}"

      child(:path, options)
    end

    def circle(center, radius, options = {})
      center = absolute_transform * center
      options = options.merge(
        :cx => center.x,
        :cy => center.y,
        :r => radius,
      )

      child(:circle, options)
    end

    def circle_segment(center, options = {})
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
      options[:closed] = (sweep - 360).abs <= 0.002 if options[:closed].nil?

      arc(start, stop, options)
    end

    def text(anchor, value, options = {})
      options[:style] ||= {
        :font_family => "Courier",
        :fill => "#000000",
        :font_size => 10,
      }
      anchor = absolute_transform * anchor
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

      closed = options.delete(:closed)
      if closed != false && options[:d].present?
        options[:d] << " z"
      end

      options
    end

    def decode_transform(data)
      return nil if data.nil?
      Marshal.load(Base64.decode64(data))
    end

  end
end