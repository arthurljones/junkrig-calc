from math import *
import ImageFont
import ImageDraw

from vec import Vec
from bounds import Bounds
from transform import Transform

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
        self.transform_stack.insert(0, self.matrix.clone())

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