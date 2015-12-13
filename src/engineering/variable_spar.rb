require "options_initializer"

require "engineering/cross_section"
require "engineering/material"
require "engineering/tapered_spar"

module Engineering
  class VariableSpar
    include OptionsInitializer

    attr_reader(*%i(
      center_of_mass
      length
      volume
      mass
      windage
      cross_sections
      spans
    ))

    options_initialize(
      material: { class: Engineering::Material, constructor: :get },
      section_type: { },
      cross_sections: { write: false },
    ) do |options|

      @cross_sections = options[:cross_sections].each_with_object({}) do |(position, cross_section), result|
        cross_section = cross_section.merge(type: @section_type) if Hash === cross_section
        result[Unit.new(position)] = Engineering::CrossSection.create(cross_section)
      end.sort.to_h

      @spans = @cross_sections.each_cons(2).each_with_object({}) do |values, result|
        pos0, pos1 = values.collect(&:first)
        section0, section1 = values.collect(&:last)
        result[pos0] = TaperedSpar.new(foot: section0, head: section1, length: pos1 - pos0, material: @material)
      end

      @length = @spans.values.sum(&:length).to("ft")
      @volume = @spans.values.sum(&:volume).to("in^3")
      @mass = @spans.values.sum(&:mass).to("lbs")
      @windage = @spans.values.sum(&:windage).to("ft^2") #TODO: Only sum areas above the deck?
      @center_of_mass = @spans.reduce(0) do |result, (pos, section)|
        result + section.mass * (pos + section.center_of_mass)
      end
      @center_of_mass = (@center_of_mass / @mass).to("ft")

      #ap length: length, volume: volume, mass: mass, winage: windage, center_of_mass: center_of_mass
    end

    def cross_section(position)
      raise ArgumentError.new("Blank position") if position.blank?
      if position < 0 || position > length
        raise ArgumentError.new("Requesting cross section at #{position} which is outside of spar (#{length}")
      end

      @spans.each do |section_start, section|
        if section_start <= position && section_start + section.length >= position
          return section.cross_section(position - section_start)
        end
      end
    end

    def yield_moment(position)
      cross_section(position).elastic_section_modulus * @material.yield_strength
    end

    def split(position)
      below = @cross_sections.select { |pos, _| pos < position }
      above = @cross_sections.select { |pos, _| pos >= position }
      section = cross_section(position)
      below[position] = section
      above[position] = section
      options = { section_type: @section_type, material: @material }

      [
        self.class.new(options.merge(stations: below)),
        self.class.new(options.merge(stations: above))
      ]
    end

    def draw_to_svg(layer, foot_position, name)
      inside_points = []
      outside_points = []
      @cross_sections.each do |position, cross_section|
        inside_points.append(Vector2.new(cross_section.inner_radius, position))
        outside_points.unshift(Vector2.new(cross_section.outer_radius, position))
      end

      right_points = inside_points + outside_points
      left_points = right_points.map { |p| Vector2.new(-p.x, p.y) }

      options = {:style => { :fill => "#000000", :fill_opacity => 0.5 }}
      layer.layer(name) do |l|
        l.local_transform = Transform.new.translated(foot_position)
        l.line_loop(left_points, options)
        l.line_loop(right_points, options)
      end
    end
  end
end
