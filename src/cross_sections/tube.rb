require_relative "../cross_section"
require_relative "../options_initializer"

module CrossSections
  class Tube
    include CrossSection
    include OptionsInitializer
    attr_reader :outer_radius, :wall_thickness

    options_initialize(
      :outer_radius => { :units => "in" },

    ) do |options|
      puts "blah"
    end

  end
end
