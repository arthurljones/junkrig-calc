require "options_initializer"

module Engineering
  class Material
    include OptionsInitializer
    @@materials_cache = nil

    attr_reader :name

    options_initialize(
      :yield_strength => { :units => "psi" },
      :density => { :units => "lbs/in^3" },
      :modulus_of_elasticity => { :units => "psi" },
      :shear_strength => { :units => "psi", :required => false },
    )

    def self.get(name)
      cache[name]
    end

    def self.list
      cache.keys
    end

    def shear_strength
      @shear_strength || yield_strength * 0.577
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

  private

    def self.cache
      unless @@materials_cache
        materials_data = load_yaml_data_file("materials.yml")
        @@materials_cache = materials_data.inject({}) do |cache, (name, data)|
          raise "Duplicate material definition for #{name}" if cache[name].present?
          cache[name] = new(data)
          cache
        end
      end
      @@materials_cache
    end
  end
end
