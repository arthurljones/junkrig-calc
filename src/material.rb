class Material

  attr_reader :name, :yield_strength, :density, :modulus_of_elasticity

  def initialize(options)
    known_opts = {
      :name => { :required => true },
      :yield_strength => { :required => true, :units => "psi" },
      :density => { :required => true, :units => "lbs/in^3" },
      :modulus_of_elasticity => { :required => true, :units => "psi" }
    }

    known_opts.each do |attribute, attr_opts|
      value = options[attribute]
      required = attr_opts[:required]
      units = attr_opts[:units]

      value = Unit(value) if units

      raise "#{attribute} is required" if required && value.blank?
      raise "#{attribute} must be convertible to #{attr_opts[:units]}" if units && value !~ units

      instance_variable_set("@#{attribute}", value)
    end
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

end
