module Engineering
  module CrossSection
    extend ActiveSupport::Concern
    included do
      def elastic_section_modulus
        second_moment_of_area / extreme_fiber_radius
      end
    end

    module_function
    def create(options)
      type = options.delete(:type)
      raise "No cross section type specified" unless type.present?
      begin
        require_relative "cross_sections/#{type}"
        klass = Engineering::CrossSections.const_get(type.to_s.camelize)
        klass.new(options)
      rescue LoadError, NameError => e
        raise "Could not find cross section named #{type}"
      end
    end
  end
end