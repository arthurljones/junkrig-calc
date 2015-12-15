require "options_initializer"
require "sheet/point"
require "math/vector2"

module Sheet
  class FreePoint
    include OptionsInitializer
    include Point

    options_initialize(
      position: { class: Vector2 },
      name: { required: false }
    ) do |options|
      original_initialize
    end
  end
end
