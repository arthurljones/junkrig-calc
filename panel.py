from vec import Vec
from batten import Batten

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