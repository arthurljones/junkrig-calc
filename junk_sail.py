#!/usr/bin/env python

from PIL import Image
import ImageFont
import ImageDraw

from math import *
import numpy as np
import transformations

class Vec(np.ndarray):
    def __new__(cls, x, y):
        return np.array([x, y]).view(cls)

    @classmethod
    def from_angle(cls, rad, mag = 1):
        return cls(cos(rad) * mag, sin(rad) * mag)

    @property
    def mag(self):
        return np.linalg.norm(self)

    @property
    def normalized(self):
        return self / self.mag

    @property
    def x(self):
        return self[0]

    @property
    def y(self):
        return self[1]

    @property
    def perp(self):
        return Vec(self[1], -self[0])

    @property
    def tup(self):
        return (self.x, self.y)

    @property
    def tup3(self):
        return (self.x, self.y, 0)

    @property
    def tup_int(self):
        return (int(self.x), int(self.y))

class Bounds(object):
    def __init__(self, minimum, maximum):
        self.min = minimum
        self.max = maximum

    @classmethod
    def from_points(cls, points):
        return Bounds(np.amin(points, 0).view(Vec), np.amax(points, 0).view(Vec))

    @property
    def tup(self):
        return self.min.tup + self.max.tup
    @property

    def tup_int(self):
        return self.min.tup_int + self.max.tup_int

    @property
    def size(self):
        return self.max - self.min

    def scaled(self, scale):
        return Bounds(self.min * scale, self.max * scale)

class Transform(np.ndarray):
    def __new__(cls):
        return np.identity(4).view(cls)

    def translated(self, vec):
        return self._transformed_by(transformations.translation_matrix(vec))
        
    def rotated(self, theta):
        return self._transformed_by(transformations.rotation_matrix(-theta, (0, 0, 1)))

    def scaled(self, scalar):
        return self._transformed_by(transformations.scale_matrix(scalar))

    def _transformed_by(self, mat):
        return np.dot(self, mat).view(type(self))

    def transform(self, vec):
        arr = np.array((vec.x, vec.y, 0, 0))
        transformed = self.dot(arr)
        translated = transformed[:3] + self[:3, 3]
        return Vec(translated[0], translated[1])

    def transform_many(self, arr):
        return [self.transform(v) for v in arr]

class DrawContext:
    def __init__(self, image):
        self.target = ImageDraw.Draw(image)
        self.font = ImageFont.truetype("Earthbound-Condensed-Bold.otf", 32)
        self.transform_stack = [Transform()]

    @property
    def matrix(self):
        return self.transform_stack[0]

    @matrix.setter
    def matrix(self, value):
        self.transform_stack[0] = value

    def push_matrix(self):
        self.transform_stack.insert(0, np.copy(self.transform))

    def pop_matrix(self):
        self.transform_stack.pop(0)

    def draw_point(self, p, color, radius = 1):
        p = self.matrix.transform(p)
        r_2 = radius * 0.5
        poly_verts = [(p + offset).tup for offset in [(r_2, r_2), (-r_2, r_2), (-r_2, -r_2), (r_2, -r_2)]]
        self.target.polygon(poly_verts, color)

    def draw_line(self, p0, p1, color, radius = 1):
        p0 = self.matrix.transform(p0)
        p1 = self.matrix.transform(p1)
        normal = (p1 - p0).perp.normalized * (radius * 0.5)
        poly_verts = [p.tup for p in [p0 + normal, p1 + normal, p1 - normal, p0 - normal]]
        self.target.polygon(poly_verts, color)

    def draw_line_loop(self, points, color, radius = 1):
        for i in range(-1, len(points) - 1):
            self.draw_line(points[i], points[i+1], color, radius)

    def draw_arc(self, center, radius, color, start = 0, end = 2*pi):
        offset = Vec(radius, radius)
        bounds = Bounds.from_points((self.matrix.transform(center - radius), self.matrix.transform(center + radius)))
        start = int(degrees(start))
        end = int(degrees(end))
        self.target.arc(bounds.tup_int, start, end, color)

    def draw_text(self, point, text, color):
        self.target.text(self.matrix.transform(point), text, color, font=self.font)

def triangle_height(side_a, side_b, base):
    p_2 = (side_a + side_b + base) / 2 #semiperimeter
    area = sqrt(p_2 * (p_2 - side_a) * (p_2 - side_b) * (p_2 - base))
    return 2 * area / base

class Batten:
    def __init__(self, length, luff_height, angle):
        self.tack = Vec(0, luff_height)
        self.clew = self.tack + Vec.from_angle(angle, length)

class Panel:
    def __init__(self, foot, head):
        self.foot = foot
        self.head = head

        area = 0
        center_x = 0
        center_y = 0
        perim = self.perimeter
        for i in range(len(perim) - 1):
            p0 = perim[i]
            p1 = perim[i + 1]
            area_component = (p0.x * p1.y - p1.x * p0.y)
            area += area_component
            center_x += (p0.x + p1.x) * area_component
            center_y += (p0.y + p1.y) * area_component

        self.area = area * 0.5
        self.center = Vec(center_x, center_y) / (self.area * 6)

        print self.area, self.center

    def draw(self, context, color, radius = 2):
        context.draw_line_loop(self.perimeter, color, radius)

    @property
    def perimeter(self):
        return (self.foot.tack, self.foot.clew, self.head.clew, self.head.tack, self.foot.tack)

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
        self.panel_width = triangle_height(batten_length, batten_length * (1. - batten_stagger), self.panel_luff) #ft
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

        image.show()
        image.save(filename, dpi=(pixels_per_inch, pixels_per_inch))

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

ppi = 3.19
sail = Sail(14, 20, 4, 3, radians(70))
sail.draw_sail(ppi, "sail.png")
sail.draw_sheet_zone(2, ppi, "sheet_anchor.png")