require "options_initializer"
require "engineering/material"

module Engineering
  class Beam
    include OptionsInitializer

    attr_reader :material, :cross_section, :length, :unsupported_length

    options_initialize(
      :material => { :required => true },
      :cross_section => { :required => true },
      :length => { :required => true, :units => "in" },
      :unsupported_length => { :units => "in" }
    ) do |options|
      #TODO: Maybe this should go in Material itself?
      unless @material.respond_to?(:yield_strength)
        case @material
        when Hash
          @material = Engineering::Material.new(@material)
        when String
          @material = Engineering::Material.get(@material) or raise "No material named #{material} found"
        else
          raise "Can't convert #{material} (#{material.class.name}) into material"
        end
      end

      unless @cross_section.respond_to?(:second_moment_of_area)
        @cross_section = Engineering::CrossSection.create(@cross_section)
      end

      @unsupported_length ||= length
    end

    def volume
      length * cross_section.area
    end

    def weight
      volume * material.density
    end

    def cantilever_end_load_limit
      base_load_limit
    end

    def cantilever_uniform_load_limit
      2 * base_load_limit
    end

    def simply_supported_center_load_limit
      4 * base_load_limit
    end

    def simply_supported_uniform_load_limit
      8 * base_load_limit
    end

    private

    def base_load_limit
      material.yield_strength * cross_section.elastic_section_modulus / unsupported_length
    end
  end
end
