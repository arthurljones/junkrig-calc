require "options_initializer"

module Engineering
  class BucklingLimits
    include OptionsInitializer

    attr_reader :effective_length_ratio

    options_initialize(
      :beam => { },
      :end_attachment => { },
      :unsupported_length => { :units => "in" },
    ) do |options|
      @unsupported_length ||= @beam.length
      @end_attachment = @end_attachment.sort
      raise "Unsupported end attachment configuration ${@end_attachment}" unless effective_length_ratio
    end

    def effective_length
      unsupported_length * effective_length_ratio
    end

    def effective_length_ratio
      self.class.effective_length_ratios[@end_attachment]
    end

    def euler
      Math::PI**2 * beam.material.modulus_of_elasticity * beam.minimum_cross_section / effective_length**2
    end

    def compressive
      beam.material.yield_strength * beam.minumum_cross_section.area
    end

    def rankine_gordon
      (euler.inverse + compressive.inverse).inverse
    end

    def self.effective_length_ratios
      {
        [:fixed, :fixed] => 0.65,
        [:fixed, :hinged] => 0.8,
        [:fixed, :guided] => 1.2,
        [:fixed, :free] => 2.1,
        [:guided, :guided] => 1.2,
        [:guided, :hinged] => 2,
        [:free, :guided] => 2.1,
        [:hinged, :hinged] => 1
      }
    end
  end
end
