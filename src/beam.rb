require_relative "options_initializer"

class Beam
  include OptionsInitializer

  attr_reader :material, :cross_section, :length, :unsupported_length

  options_initialize(
    :material => { :required => true },
    :cross_section => { :required => true },
    :length => { :required => true, :units => "in" },
    :unsupported_length => { :units => "in" }
  ) do |options|
    @material = Material.new(@material) unless @material.respond_to?(:is_material?) && @material.is_material?
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
