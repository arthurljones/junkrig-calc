from math import *

def triangle_height(side_a, side_b, base):
    p_2 = (side_a + side_b + base) / 2 #semiperimeter
    area = sqrt(p_2 * (p_2 - side_a) * (p_2 - side_b) * (p_2 - base))
    return 2 * area / base
