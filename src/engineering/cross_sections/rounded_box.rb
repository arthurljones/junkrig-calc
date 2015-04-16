require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require_relative "box"
require_relative "semicircle"
require "options_initializer"

module Engineering
  module CrossSections
    class RoundedBox
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :height, :width, :wall_thickness, :corner_radius, :defect_width, :gusset_size, :minimum_thickness

      options_initialize(
        :height => { :units => "in" },
        :width => { :units => "in" },
        :wall_thickness => { :required => false, :units => "in" },
        :corner_radius => { :required => false, :units => "in" },
        :defect_width => { :units => "in", :default => "0 in" },
        :gusset_size => { :units => "in", :default => "0 in" },
      ) do |options|

        @top_thickness = @wall_thickness || @width / 2
        @side_thickness = @wall_thickness || @height / 2

        @inner_height = @height - 2 * @top_thickness
        @inner_width = @width - 2 * @side_thickness

        raise "Impossibly large corner radius" if @corner_radius > @height / 2 || @corner_radius > @width / 2
        raise "Impossibly large gussets" if @gusset_size > @inner_height / 2 || @gusset_size > @inner_width / 2

        @minimum_thickness = minimum_thickness

        @section = box + gussets - radius_material_removed - wall_defects

        @extreme_fiber_radius = @section.extreme_fiber_radius
        @area = @section.area
        @second_moment_of_area = @section.second_moment_of_area
      end

      def radius_material_removed
        square_distance = (@height - @corner_radius) / 2
        square = Box.new(:height => @corner_radius, :width => @corner_radius).offset(square_distance)

        radiused = Semicircle.new(:radius => @corner_radius)
        radiused_distance = square_distance + radiused.centroid_from_base
        radiused = radiused.offset(radiused_distance) / 2

        (square - radiused) * 4
      end

      def wall_defects
        #Calculates worst-case scenario: defect on strength surface plus defect on side
        # surface close to the radiused corner
        top_offset = (@height - @top_thickness) / 2
        top_defect = Box.new(:height => @side_thickness, :width => @defect_width).offset(top_offset)
        side_offset = (@height  - @defect_width) / 2 - @corner_radius
        side_defect = Box.new(:height => @side_thickness, :width => @defect_width).offset(side_offset)

        (side_defect + top_defect) * 2
      end

      def gussets
        gusset_offset = (@inner_height - @gusset_size) / 2
        Box.new(:height => @gusset_size, :width => @gusset_size).offset(gusset_offset) * 4
      end

      def box
        outer_box = Box.new(:height => @height, :width => @width)
        inner_space = Box.new(:height => @inner_height, :width => @inner_width)
        outer_box - inner_space
      end

      def minimum_thickness
        minimum_thickness = [@top_thickness, @side_thickness].min
        if @corner_radius > minimum_thickness + @gusset_size

          minimum_radius = [@top_thickness, @side_thickness].max_by do |thickness|
            ((@corner_radius - thickness - @gusset_size) ** 2 + (@corner_radius - thickness) ** 2) ** 0.5
          end

          puts "Warning: Corner radius reduces minimum thickness to less than thinnest wall"
          minimum_thickness = @gusset_size - minimum_radius
        end

        minimum_thickness
      end
    end
  end
end
