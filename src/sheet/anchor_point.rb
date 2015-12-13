require "options_initializer"
require "sheet/point"
require "math/vector2"

module Sheet
  class AnchorPoint
    include OptionsInitializer
    include Point

    options_initialize(
      position: { class: Vector2 },
    ) do |options|
      @force_to_position = Unit.new("0 in/lbf")
      original_initialize
    end
  end
end
