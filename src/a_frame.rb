require "options_initializer"

require "engineering/cross_section"
require "engineering/material"

class AFrame
  include OptionsInitializer

  attr_reader *%i(
  )

  options_initialize(
    height: { units: "in" },
    base_width: { units: "in" },
    top_width: { units: "in" },
    crossmember_height: { units: "in" },
    material: { constructor: ->(mat) { Engineering::Material.get(mat) } },
    cross_section:  { constructor: ->(opts) { Engineering::CrossSection.create(opts) } },
  ) do |options|
    load_direction = Math::PI / 2

    leg_angle = Math::atan2(@height, (@base_width - @top_width)/2)
    

    length = 1
    unsupported_length = 1



    @beam = Engineering::Beam.new(
          material: @material,
          cross_section: @cross_section,
          length: length,
          attachment_type: [:pinned, :pinned],
          unsupported_length: unsupported_length
          )

  end

end
