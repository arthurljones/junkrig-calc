class Material
  attr_reader :name, :yield_strength, :density, :modulus_of_elasticity

  def shear_yield_strength
    yield_strength * 0.577
  end

  def strength_to_density_ratio
    (yield_strength / density) / 1e5
  end

end
