require "options_initializer"
require "engineering/cross_section"
require "engineering/material"

module Engineering
  class TaperedSpar
    include OptionsInitializer

    attr_reader *%i(
      center_of_mass
      volume
      mass
      windage
    )

    options_initialize(
      length: { units: "in" },
      material: { class: Engineering::Material, costructor: :get },
      foot: { class: Engineering::CrossSection, constructor: :create },
      head: { class: Engineering::CrossSection, constructor: :create },
    ) do |options|
      @center_of_mass = (@head.area / (@foot.area + @head.area)) * @length
      @volume = (@foot.area + @head.area) / 2 * @length
      @mass = @volume * @material.density
      @windage = (@foot.extreme_fiber_radius + @head.extreme_fiber_radius) * @length
    end

    def cross_section(position)
      raise ArgumentError.new("Requesting cross section outside of spar: #{position}") if position < 0 || position > length
      @foot.interpolate(@head, position / @length)
    end
  end
end
