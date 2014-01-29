from math import *
from sail import Sail

ppi = 3.19
sail = Sail(14, 20, 4, 3, radians(70))
sail.draw_sail(ppi, "sail.png")
sail.draw_measurements(ppi, "measurements_lines.png", "measurements_numbers.png")
sail.draw_sheet_zone(2, ppi, "sheet_anchor.png")