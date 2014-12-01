require "options_initializer"

module Engineering
  class Material
    include OptionsInitializer
    @@materials_cache = nil

    options_initialize(
      :yield_strength => { :units => "psi" },
      :density => { :units => "lbs/in^3" },
      :modulus_of_elasticity => { :units => "psi" }
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

  private

    def self.cache
      unless @@materials_cache
        root = File.expand_path(File.dirname(__FILE__))
        materials_data = YAML.load_file(File.join(root, "..", "..", "materials.yml")).with_indifferent_access
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
