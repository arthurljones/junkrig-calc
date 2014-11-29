require_relative "options_initializer"

class Material
  include OptionsInitializer
  attr_reader :yield_strength, :density, :modulus_of_elasticity

  options_initialize(
    :yield_strength => { :required => true, :units => "psi" },
    :density => { :required => true, :units => "lbs/in^3" },
    :modulus_of_elasticity => { :required => true, :units => "psi" }
  )

  def self.get(name)
    cache[name]
  end

  def self.list
    cache.keys
  end

  def shear_yield_strength
    yield_strength * 0.577
  end

  def strength_to_density_ratio
    ((yield_strength / density) / 1e5).scalar
  end

  def to_s
    name
  end

  def inspect
    to_s
  end

  def is_material?
    true
  end

private

  def self.cache
    root = File.expand_path(File.dirname(__FILE__))
    @@materials_cache ||= YAML.load_file(File.join(root, "..", "materials.yml")).with_indifferent_access
  end

end
