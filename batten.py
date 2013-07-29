from vec import Vec

class Batten:
    def __init__(self, length, luff_height, angle):
        self.tack = Vec(0, luff_height)
        self.clew = self.tack + Vec.from_angle(angle, length)
