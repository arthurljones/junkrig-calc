from PIL import Image

from math import *
from vec import Vec
from bounds import Bounds
from transform import Transform
from draw_context import DrawContext
from batten import Batten
from panel import Panel

import util

class Sail:
    def __init__(self, luff, batten_length, lower_panels, head_panels, yard_angle):
        batten_stagger = 0.01
        batten_length_to_head_panel_luff_in = 9./25.
        batten_length_to_mast_offset = 0.05
        batten_length_to_mast_tip_length = 0.15
        in_to_ft = 1. / 12.

        self.luff = luff
        self.batten_length = batten_length
        self.lower_panels = lower_panels
        self.head_panels = head_panels
        self.total_panels = lower_panels + head_panels
        self.yard_angle = yard_angle

        self.panel_luff = float(luff) / lower_panels #ft
        self.panel_width = util.triangle_height(batten_length, batten_length * (1. - batten_stagger), self.panel_luff) #ft
        self.tack_angle = pi/2 - asin(self.panel_width / batten_length) #rad
        self.clew_rise = self.batten_length * sin(self.tack_angle) #ft
        self.head_panel_luff = round(self.batten_length * batten_length_to_head_panel_luff_in, 0) * in_to_ft

        self.tack = Vec(0, 0)
        self.clew = Vec(self.panel_width, self.clew_rise)
        self.yard_span = Vec.from_angle(yard_angle, self.batten_length)
        self.throat = Vec(0, self.luff + self.head_panel_luff * self.head_panels)
        self.peak = self.throat + self.yard_span
        self.sling_point = self.throat + self.yard_span * 0.5
        self.mast_from_tack = self.sling_point.x - self.batten_length * batten_length_to_mast_offset

        bounding_points = (self.tack, self.clew, self.throat, self.peak)
        self.bounds = Bounds.from_points(bounding_points)

        make_lower_batten = lambda i: Batten(batten_length, self.panel_luff * i, self.tack_angle)
        self.battens = [make_lower_batten(i) for i in range(self.lower_panels + 1)]

        head_panel_angle = (self.yard_angle - self.tack_angle) / head_panels
        make_head_batten = lambda i: Batten(batten_length, self.luff + self.head_panel_luff * i, self.tack_angle + head_panel_angle * i)
        self.battens.extend([make_head_batten(i) for i in range(1, self.head_panels + 1)])

        self.panels = [Panel(self.battens[i], self.battens[i+1]) for i in range(len(self.battens) - 1)]
        self.area = sum(p.area for p in self.panels)

        area = 0
        center_x = 0
        center_y = 0
        for panel in self.panels:
            area += panel.area
            center_x += panel.center.x * panel.area
            center_y += panel.center.y * panel.area
        self.area = area
        self.center = Vec(center_x, center_y) / area

        print self.area, self.center

    def make_image_and_context(pixels_per_inch, margin = 100):
        pixels_per_foot = pixels_per_inch * 12
        margin = 100
        size = (self.bounds.scaled(pixels_per_foot).size + Vec(margin * 2, margin * 2)).tup_int
        translation = (size[0] - margin, size[1] - margin, 0)
        rotation = radians(180)
        scale = pixels_per_foot

        image = Image.new("RGBA", size, 0xFFFFFFFF)
        context = DrawContext(lines_image)
        context.matrix = context.matrix.translated(translation).rotated(rotation).scaled(scale)

    def draw_sail(self, pixels_per_inch, filename):
        pixels_per_foot = pixels_per_inch * 12
        size = (self.bounds.scaled(pixels_per_foot).size + Vec(20, 20)).tup_int
        #size = 2000, 3000
        print "size: ", size
        image = Image.new("RGBA", size, 0xFFFFFFFF)
        context = DrawContext(image)
        context.matrix = context.matrix.translated((size[0] - 10, size[1] - 10, 0)).rotated(radians(180)).scaled(pixels_per_foot)

        color = 0xFF000000

        for panel in self.panels:
            panel.draw(context, color)

        mast_line_center = Vec(self.mast_from_tack, self.sling_point.y)
        offset = Vec(0, 1)
        context.draw_line(mast_line_center - offset, mast_line_center + offset, color, 2)
        context.draw_arc(self.sling_point, 0.25, color)

        context.draw_arc(self.center, 0.25, color)
        context.draw_point(self.center, color, 3)
        context.draw_text(self.center + Vec(0.4, -0.3), "{} sq ft".format(int(self.area)), color)

        context.draw_point(Vec(0, 0), color, 10)

        image.save(filename, dpi=(pixels_per_inch, pixels_per_inch))

    def draw_measurements(self, pixels_per_inch, lines_filename, numbers_filename):
        pixels_per_foot = pixels_per_inch * 12
        margin = 100
        size = (self.bounds.scaled(pixels_per_foot).size + Vec(margin * 2, margin * 2)).tup_int
        translation = (size[0] - margin, size[1] - margin, 0)
        rotation = radians(180)
        scale = pixels_per_foot

        lines_image = Image.new("RGBA", size, 0xFFFFFFFF)
        lines_context = DrawContext(lines_image)
        lines_context.matrix = lines_context.matrix.translated(translation).rotated(rotation).scaled(scale)

        numbers_image = Image.new("RGBA", size, 0xFFFFFFFF)
        numbers_context = DrawContext(numbers_image)
        numbers_context.matrix = numbers_context.matrix.translated(translation).rotated(rotation).scaled(scale)

        color = 0xFF2222AA

        def feet_and_inches_string(distance):
            feet = int(floor(distance))
            inches = (distance % 1) * 12
            inches = round(inches / 0.25) * 0.25 #Round to quarters
            inch_fraction = int((inches % 1) * 4)
            inches = int(inches)

            if feet < 2:
                inches += feet * 12
                feet = 0

            text = ""
            if feet > 0:
                text += "{}' ".format(feet)

            if inches > 0 or inch_fraction > 0:
                if inches > 0:
                    text += "{}".format(inches)

                if inch_fraction == 1:
                    text += "-1/4"
                if inch_fraction == 2:
                    text += "-1/2"
                if inch_fraction == 3:
                    text += "-3/4"

                text += "\""

            return text

        def draw_length_line(p1, p2, ratio = 0.5, offset = Vec(0, 0)):
            delta = p2 - p1
            distance = delta.mag
            lines_context.draw_line(p1, p2, color, 2)
            numbers_context.draw_text(p1 + (delta * ratio) + offset, feet_and_inches_string(distance), color) #.

        b0 = self.battens[0]
        b1 = self.battens[self.lower_panels]
        b3 = self.battens[-1]

        numbers_context.draw_line(b0.clew, b0.tack, color, 2) #For alignment

        draw_length_line(b0.clew, b0.tack, 0.5, Vec(0, 1))
        draw_length_line(b1.clew, b1.tack, 0.5, Vec(0, -0.5))

        draw_length_line(b1.clew, b3.tack, 0.5, Vec(0, 1))
        draw_length_line(b1.tack, b3.tack, 0.5, Vec(-0.1, 0.5))

        draw_length_line(b0.clew, b1.tack, 0.25)
        draw_length_line(b0.tack, b1.clew, 0.75, Vec(0, 1))

        draw_length_line(b0.tack, b1.tack, 0.5, Vec(1.5, 0))
        draw_length_line(b0.clew, b1.clew)

        for i in range(self.lower_panels + 1, len(self.battens)):
            b2 = self.battens[i]
            draw_length_line(b1.clew, b2.clew)
            draw_length_line(b1.tack, b2.clew)

        lines_image.save(lines_filename, dpi=(pixels_per_inch, pixels_per_inch))
        numbers_image.save(numbers_filename, dpi=(pixels_per_inch, pixels_per_inch))

    def draw_sheet_zone(self, d_min_ratio, pixels_per_inch, filename):
        pixels_per_foot = pixels_per_inch * 12

        #Assumptions
        leech_angle = 3*pi/2
        panel_leech = self.panel_luff

        start =  pi - self.tack_angle + radians(30)
        end = leech_angle - radians(10)

        d_min = d_min_ratio * panel_leech
        d_outer = (d_min_ratio + 1.5) * panel_leech

        top = Vec.from_angle(start)
        bot = Vec.from_angle(end)

        top_points = (top * d_min, top * d_outer)
        bot_points = (bot * d_min, bot * d_outer)

        hull = [top_points[0], top_points[1], bot_points[0], bot_points[1], Vec(0, 0)]
        bounds = Bounds.from_points(hull).scaled(pixels_per_foot)

        size = (bounds.size + Vec(21, 21)).tup_int
        image = Image.new("RGBA", size, 0x00000000)
        context = DrawContext(image)
        context.matrix = context.matrix.translated((-bounds.min + Vec(10, 10)).tup3).scaled(pixels_per_foot) #[size[0] + 10, size[1] + 10,

        color = 0xFF000000
        context.draw_arc(Vec(0, 0), d_min, color, start, end)
        context.draw_arc(Vec(0, 0), d_outer, color, start, end)
        context.draw_line(top_points[0], top_points[1], color)
        context.draw_line(bot_points[0], bot_points[1], color)
        context.draw_point(Vec(0, 0), color, 3)

        result = image.transpose(Image.FLIP_TOP_BOTTOM)
        result.save(filename, dpi=(pixels_per_inch, pixels_per_inch))
