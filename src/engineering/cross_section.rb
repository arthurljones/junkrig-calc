module Engineering
  module CrossSection
    extend ActiveSupport::Concern
    included do
      #These must be implemented by subclasses
      attr_reader :area, :second_moment_of_area, :extreme_fiber_radius

      def elastic_section_modulus
        second_moment_of_area / extreme_fiber_radius
      end

      def neutral_axis_through_centroid
        true
      end

      def structure_prefix(depth)
        "#{"| "*(depth)}#{self.class.name.demodulize}"
      end

      def structure_content(depth, &block)
        ""
      end

      def structure_string(depth = 0, &block)
        result = "#{structure_prefix(depth)}"
        result += " (#{yield(self)})" if block_given?
        result += ": #{structure_content(depth, &block)}"
        result
      end

      def to_s
        structure_string
      end
    end

    module_function
    def create(options)
      type = options.delete(:type)
      raise "No cross section type specified" unless type.present?
      klass = nil
      begin
        require_relative "cross_sections/#{type}"
        klass = Engineering::CrossSections.const_get(type.to_s.camelize)
      rescue LoadError, NameError => e
        raise "Could not find cross section named #{type}"
      end

      klass.new(options) if klass
    end
  end
end
