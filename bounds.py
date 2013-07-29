from math import *
import numpy as np
from vec import Vec

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