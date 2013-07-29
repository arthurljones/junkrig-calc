from math import *
import numpy as np

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