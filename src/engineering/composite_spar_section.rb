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
      if contains(position)
        yield_moment_ = yield_moment(position)
        result = (yield_moment_ / max_moment).to(Unit.new(1)).scalar
        #ap position: position, max_moment: max_moment.to("ft*lbf"), yield_moment: yield_moment_.to("ft*lbf"), safety: result
        result
      end
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
