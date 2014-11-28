module CrossSection
  extend ActiveSupport::Concern
  included do
    def section_modulus
      second_moment_of_area / extreme_fiber_radius
    end
  end
end
