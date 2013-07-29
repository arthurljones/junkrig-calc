from math import *
import numpy as np
import transformations as trns
from vec import Vec

class Transform(np.ndarray):
    def __new__(cls):
        return np.identity(4).view(cls)

    def translated(self, vec):
        return self._transformed_by(trns.translation_matrix(vec))
        
    def rotated(self, theta):
        return self._transformed_by(trns.rotation_matrix(-theta, (0, 0, 1)))

    def scaled(self, scalar):
        return self._transformed_by(trns.scale_matrix(scalar))

    def _transformed_by(self, mat):
        return np.dot(self, mat).view(type(self))

    def transform(self, vec):
        arr = np.array((vec.x, vec.y, 0, 0))
        transformed = self.dot(arr)
        translated = transformed[:3] + self[:3, 3]
        return Vec(translated[0], translated[1])

    def transform_many(self, arr):
        return [self.transform(v) for v in arr]