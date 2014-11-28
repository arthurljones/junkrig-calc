require_relative "options_initializer"

class Material
  include OptionsInitializer
  attr_reader :name, :yield_strength, :density, :modulus_of_elasticity

  options_initialize(
    :name => { :required => true },
    :yield_strength => { :required => true, :units => "psi" },
    :density => { :required => true, :units => "lbs/in^3" },
    :modulus_of_elasticity => { :required => true, :units => "psi" }
  )

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

end
