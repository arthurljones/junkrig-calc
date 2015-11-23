require "options_initializer"
require "engineering/cross_section"
require "engineering/material"

module Engineering
  class Beam
    ATTACHMENT_MODES = {
      [:fixed,  :fixed ] => { length_ratio: 0.65, load_modifiers: { point: 8,   uniform: 24  } },
      [:fixed,  :hinged] => { length_ratio: 0.8,  load_modifiers: { point: nil, uniform: 8   } },
      [:fixed,  :guided] => { length_ratio: 1.2,  load_modifiers: { point: 2,   uniform: 3   } },
      [:fixed,  :free  ] => { length_ratio: 2.1,  load_modifiers: { point: 1,   uniform: 2   } },
      [:guided, :guided] => { length_ratio: 1.2,  load_modifiers: { point: nil, uniform: nil } },
      [:guided, :hinged] => { length_ratio: 2,    load_modifiers: { point: nil, uniform: nil } },
      [:free,   :guided] => { length_ratio: 2.1,  load_modifiers: { point: nil, uniform: nil } },
      [:hinged, :hinged] => { length_ratio: 1,    load_modifiers: { point: 4,   uniform: 8   } }
    }

    include OptionsInitializer

    attr_reader *%i(
      volume
      weight
      buckling_load_limit
      min_point_load_limit
      min_uniform_load_limit
    )

    options_initialize(
      :material => { },
      :cross_section => { },
      :length => { :units => "in" },
      :attachment_type => { :default => [:fixed, :free] },
      :unsupported_length => { :required => false, :units => "in" }
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

      @volume = length * cross_section.area
      @weight = volume * material.density

      @attachment_type = @attachment_type.sort
      attachment_data = ATTACHMENT_MODES[@attachment_type]
      raise "Unsupported end attachment configuration ${@end_attachment}" unless attachment_data

      effective_length_ratio = attachment_data[:length_ratio]
      effective_length = @unsupported_length * effective_length_ratio
      euler_limit = Math::PI**2 * @material.modulus_of_elasticity * @cross_section.second_moment_of_area / effective_length**2
      compressive_limit = @material.yield_strength * @cross_section.area

      @buckling_load_limit = (euler_limit.inverse + compressive_limit.inverse).inverse #Rankine-Gordon

      base_load_limit = @material.yield_strength * @cross_section.elastic_section_modulus / @unsupported_length
      load_modifiers = attachment_data[:load_modifiers]

      #The maximum load that can be applied at the least supported point on the beam
      @min_point_load_limit = base_load_limit * (load_modifiers[:point] || Float::NAN)

      #The maximum load that can be applied uniformly along the length of the beam"
      @min_uniform_load_limit = base_load_limit * (load_modifiers[:uniform] || Float::NAN)
    end
  end
end
