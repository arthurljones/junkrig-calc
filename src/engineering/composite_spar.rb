require "options_initializer"
require "engineering/composite_spar_section"

module Engineering
  class CompositeSpar
    include OptionsInitializer

    attr_reader *%i(
      sections
      foot
      head
      length
      mass
      windage
      center_of_mass
    )

    options_initialize(
      sections: { write: false },
    ) do |options|

      @sections = options[:sections].collect do |section_options|
        CompositeSparSection.new(section_options)
      end

      @foot = @sections.map(&:foot).min
      @head = @sections.map(&:head).max
      @length = @head - @foot
      @mass = @sections.sum{ |section| section.spar.mass }
      @windage = @sections.sum{ |section| section.spar.windage } #TODO: Only sum windage above partners
      @center_of_mass = @sections.reduce(0) do |result, section|
        result + section.spar.mass * (section.foot + section.spar.center_of_mass)
      end
      @center_of_mass = (@center_of_mass / @mass).to("ft")
    end

    def safety_factors(units = "in", &moment)
      start_scalar = @foot.to(units).scalar.to_i
      end_scalar = @head.to(units).scalar.to_i
      positions = []
      result = Hash.new{ |hash, key| hash[key] = [] }

      (start_scalar..end_scalar).step(1).each do |position_scalar|
        position = Unit.new(position_scalar, units)
        max_moment = [moment.call(position), Unit.new("1 ft*lbf")].max

        positions << position
        @sections.each do |section|
          result[section] << section.safety_factor(position, max_moment)
        end
      end
      result[:positions] = positions
      result
    end

    def safety_factor(position, max_moment)
      @sections.map{ |section| section.safety_factor(position, moment) }.min
    end

    def yield_moment(position)
      @sections.each_with_object({}) do |section, result|
        result[section] = section.yield_moment(position) if section.contains(position)
      end
    end

    def cross_sections(position)
      @sections.each_with_object({}) do |section, result|
        result[section] = section.cross_section(position) if section.contains(position)
      end
    end

    def draw_to_svg(layer, partners_position)
      @sections.each { |section| section.draw_to_svg(layer, partners_position) }
    end

  end
end
