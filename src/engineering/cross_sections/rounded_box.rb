require_relative "../../math/vector2"
require_relative "../cross_section"
require_relative "compositable"
require_relative "multipliable"
require_relative "offsettable"
require_relative "box"
require_relative "semicircle"
require_relative "defect"

require "options_initializer"

module Engineering
  module CrossSections
    class RoundedBox
      include CrossSection
      include OptionsInitializer
      include Compositable
      include Multipliable
      include Offsettable

      attr_reader :height, :width, :wall_thickness, :corner_radius, :defect_width, :gusset_size, :minimum_thickness, :circumference

      options_initialize(
        :height => { :units => "in" },
        :width => { :units => "in" },
        :wall_thickness => { :required => false, :units => "in" },
        :corner_radius => { :required => false, :units => "in" },
        :defect_width => { :units => "in", :default => "0 in" },
        :gusset_size => { :units => "in", :default => "0 in" },
      ) do |options|

        @top_thickness = @wall_thickness || @height / 2
        @side_thickness = @wall_thickness || @width / 2

        @inner_height = @height - 2 * @top_thickness
        @inner_width = @width - 2 * @side_thickness

        narrowest_outer_radius = [@width, @height].min / 2
        narrowest_inner_radius = [@inner_width, @inner_height].min / 2

        raise "Top thickness (#{@top_thickness}) cannot be larger than half height (#{@height / 2})" if @inner_height < 0
        raise "Side thickness (#{@side_thickness}) cannot be larger than half width (#{@width / 2})" if @inner_width < 0
        raise "Corner radius (#{@corner_radius}) cannot be larger than half the narrowest outer dimension (#{narrowest_outer_radius})" if @corner_radius > narrowest_outer_radius
        raise "Gusset size (#{@gusset_size}) cannot be larger than half the narrowest inner dimension (#{narrowest_inner_radius})" if @gusset_size > narrowest_inner_radius

        @minimum_thickness = minimum_thickness

        @section = box + gussets - radius_material_removed + wall_defects

        @extreme_fiber_radius = @section.extreme_fiber_radius
        @area = @section.area
        @second_moment_of_area = @section.second_moment_of_area
        @circumference = (@height + @width) * 2 + @corner_radius * (2 * Math::PI - 8);
      end

      def radius_material_removed
        radius_start = @height/2 - @corner_radius
        square = Box.new(:height => @corner_radius, :width => @corner_radius).offset(radius_start + @corner_radius/2)

        radiused = Semicircle.new(:radius => @corner_radius)
        radiused_distance = radius_start + radiused.centroid_from_base
        radiused = radiused.offset(radiused_distance) / 2

        (square - radiused) * 4
      end

      def wall_defects
        #Calculates worst-case scenario: defect on strength surface plus defect on side
        # surface close to the radiused corner
        top_offset = (@height - @top_thickness) / 2
        top_defect = Box.new(:height => @side_thickness, :width => @defect_width).offset(top_offset)
        side_offset = (@height - @defect_width) / 2 - @corner_radius
        side_defect = Box.new(:height => @defect_width, :width => @side_thickness).offset(side_offset)

        Defect.new(:section => (side_defect + top_defect) * 2)
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
        outer_corner = Vector2.new(@width/2, @height/2)
        inner_corner = outer_corner - Vector2.new(@side_thickness, @top_thickness)
        radius_center = outer_corner - Vector2.new(@corner_radius, @corner_radius)
        gusset_offsets = [[0, @gusset_size], [@gusset_size, 0]]
        displacements = gusset_offsets.map{|offset| (inner_corner - Vector2.new(*offset)) - radius_center}
        displacements.reject!{|disp| disp.x < 0 || disp.y < 0}
        min_thickness = displacements.map{|disp| @corner_radius - disp.magnitude}.min || "0 in"
        min_thickness = [[@side_thickness, @top_thickness].min, min_thickness].max

        if min_thickness < 0
          raise "Corner radius (#{corner_radius}) causes negative thickness"
        end

        min_thickness
      end

      def structure_content(depth = 0, &block)
        "\n#{@section.structure_string(depth + 1, &block)}"
      end
    end
  end
end
