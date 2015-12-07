require "options_initializer"
require "engineering/variable_spar"
require "math/transform"
require "math/vector2"

module Engineering
  class CompositeSparSection
    include OptionsInitializer

    attr_reader *%i(
      head
    )

    options_initialize(
      spar: { class: VariableSpar },
      foot: { units: "in" },
      name: { }
    ) do |options|
      @head = @foot + @spar.length
    end

    def safety_factor(position, max_moment)
      return nil unless contains(position)
      (yield_moment(position) / max_moment).to(Unit.new(1)).scalar
    end

    def yield_moment(position)
      @spar.yield_moment(position - @foot)
    end

    def cross_section(position)
      @spar.cross_section(position - @foot)
    end

    def contains(position)
      position >= @foot && position <= @head
    end

    def draw_to_svg(layer, partners_position)
      @spar.draw_to_svg(layer, partners_position + Vector2.new("0 in", @foot))
    end
  end
end
