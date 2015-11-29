require "math/transform"
require "math/bounds"
require "math/vector2"
require "svg/node"

module Sail
  module SVGDrawable
    extend ActiveSupport::Concern
    included do

      def draw_to_svg(svg, upper_mast, upper_origin, lower_mast, lower_origin)
        svg.layer("Sail") do |outer_layer|
          draw_sail(outer_layer)
          draw_sheet_zone(outer_layer)
          draw_mast(outer_layer, upper_mast, "Upper Mast", upper_origin)
          draw_mast(outer_layer, lower_mast, "Lower Mast", lower_origin)
          #sail.draw_measurements(outer_layer)
        end
      end

      def draw_to_file(filename, upper_mast, upper_origin, lower_mast, lower_origin)
        bounds = image_bounds
        image_size = bounds.size.to("in")
        svg = SVG::Node.new_document(
          :width => image_size.x.to_s,
          :height => image_size.y.to_s,
          :viewBox => "0 0 #{image_size.x.scalar.round(4)} #{image_size.y.scalar.round(4)}"
        )
        transform = Transform.new.scaled(Vector2.new(-1, -1)).translated(-bounds.max)
        svg.local_transform = transform
        draw_to_svg(svg, upper_mast, upper_origin, lower_mast, lower_origin)

        File.open(filename, "wb") do |file|
          file.write(svg.node.to_xml)
          file.close
        end
      end

      def image_bounds
        Bounds.from_points([tack, clew, throat, peak])
      end

    private

      def draw_sail(group)
        sq_ft = area.to("ft^2").scalar.to_i
        sq_m = area.to("m^2").scalar.round(1)
        area_string = "#{sq_ft}ft² #{sq_m}m²"
        ap "Sail Area: #{area_string}"

        group.layer("Panels") { |l| panels.each { |panel| l.line_loop(panel.perimeter) } }
        group.layer("Mast Distance") { |l| l.circle(sling_point, sling_point_to_mast_center) }
        group.layer("Sling Point") { |l| l.circle(sling_point, Unit.new(3, "in")) }
        group.layer("Center of Effort") { |l| l.circle(center, Unit.new(3, "in")) }
        group.layer("Area") { |l| l.text(center + Vector2.new("0 in", "-18 in"), "#{area_string}") }
      end

      def draw_mast(group, mast, layer_name, origin)
        inside_points = []
        outside_points = []
        mast.cross_sections.each do |position, cross_section|
          inside_points.append(Vector2.new(cross_section.inner_radius, position) + origin)
          outside_points.unshift(Vector2.new(cross_section.outer_radius, position) + origin)
        end

        right_points = inside_points + outside_points
        left_points = right_points.map { |p| Vector2.new(origin.x * 2 - p.x, p.y) }

        options = {:style => { :fill => "#000000", :fill_opacity => 0.5 }} #TODO
        group.layer(layer_name) do |l|
          l.line_loop(left_points, options)
          l.line_loop(right_points, options)
        end
      end

      def draw_sheet_zone(group)
        pi = Unit.new(Math::PI, "rad")

        #Assumptions
        leech_angle = Unit.new(270, "deg")

        start = pi - tack_angle + Unit.new(30, "deg")
        stop = leech_angle - Unit.new(10, "deg")

        d_min = inner_sheet_distance
        d_outer = outer_sheet_distance

        top = Vector2.from_angle(start)
        bot = Vector2.from_angle(stop)

        arc1 = [top * d_min, bot * d_min]
        arc2 = [bot * d_outer, top * d_outer]

        group.layer("Sheet Zone") do |layer|
          layer.local_transform = Transform.new.translated(clew).scaled(Vector2.new(-1, 1))
          layer.build_path(:style => { :fill => "#000000", :fill_opacity => 0.1 }) do |path|
            path.move(arc1[0])
            path.arc(arc1[1], d_min, 0, false, false)
            path.line(arc2[0])
            path.arc(arc2[1], d_outer, 0, false, true)
          end
        end
      end

      def draw_measurements(svg)
        color = 0xFF2222AA

        def draw_length_line(p1, p2, ratio = 0.5, offset = Vector2.new(0, 0))
          delta = p2 - p1
          distance = delta.mag
          lines_context.draw_line(p1, p2, color, 2)
          numbers_context.draw_text(p1 + (delta * ratio) + offset, inches_and_eighths(distance), color)
        end

        b0 = battens[0]
        b1 = battens[lower_panel_count]
        b3 = battens[-1]

        numbers_context.draw_line(b0.clew, b0.tack, color, 2) #For alignment

        draw_length_line(b0.clew, b0.tack, 0.5, Vector2.new(0, 1))
        draw_length_line(b1.clew, b1.tack, 0.5, Vector2.new(0, -0.5))

        draw_length_line(b1.clew, b3.tack, 0.5, Vector2.new(0, 1))
        draw_length_line(b1.tack, b3.tack, 0.5, Vector2.new(-0.1, 0.5))

        draw_length_line(b0.clew, b1.tack, 0.25)
        draw_length_line(b0.tack, b1.clew, 0.75, Vector2.new(0, 1))

        draw_length_line(b0.tack, b1.tack, 0.5, Vector2.new(1.5, 0))
        draw_length_line(b0.clew, b1.clew)

        battens[lower_panel_count + 1 ... battens.size].each do |b2|
          draw_length_line(b1.clew, b2.clew)
          draw_length_line(b1.tack, b2.clew)
        end

        lines_image.save(lines_filename, :dpi=>[pixels_per_inch, pixels_per_inch])
        numbers_image.save(numbers_filename, :dpi=>[pixels_per_inch, pixels_per_inch])
      end
    end
  end
end
