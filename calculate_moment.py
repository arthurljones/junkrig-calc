import math, numpy, time
from PIL import Image

def MakeImage(side, pixels_per_unit):
	image = Image.new("RGBA", (int(side * pixels_per_unit * 2) + 10, int(side * pixels_per_unit * 2) + 10), 0x00000000)
	pixels = image.load()

	return (image, pixels)

def PlotPixels(image, pixels, x, y, pixels_per_unit):
	x_offset = x * pixels_per_unit
	y_offset = y * pixels_per_unit
	center = image.size[0] / 2

	for x_sign in [-1, 1]:
		for y_sign in [-1, 1]:
			x_actual = int(center + x_offset * x_sign)
			y_actual = int(center + y_offset * y_sign)
			pixels[x_actual, y_actual] = pixels[x_actual, y_actual][1] + 0xAA000000
			pixels[y_actual, x_actual] = pixels[y_actual, x_actual][1] + 0xAA000000

def DiagonalMoment(outside, thickness, pixels_per_unit):
	step_size = 1.0/pixels_per_unit
	step_weight = 1.0/pixels_per_unit**2
	cos_45 = 0.70710678118
	r = thickness * 2
	d_i = (outside - 2*r) * cos_45
	d_m = (outside - 2*thickness) * cos_45
	d_o = outside * cos_45

	x_min = d_m / 2
	x_max = d_i + r

	moment = 0.0

	image, pixels = MakeImage(x_max, pixels_per_unit)
	
	for x in numpy.arange(x_min, x_max, step_size):
		y_min = 0.0
		y_max = d_o - x
		if x < y_max:
			y_max = x

		for y in numpy.arange(y_min, y_max, step_size):
			point_inside = False
			if y <= x - d_i:
				dist = (x - d_i)**2 + y**2
				if dist <= r**2:
					point_inside = True
			elif y >= d_m - x:
					point_inside = True
			
			if point_inside:
				moment = moment + (y**2 + x**2) * step_weight
				PlotPixels(image, pixels, x, y, pixels_per_unit)
	
	image.save("moment_diagonal.png", dpi=(pixels_per_unit, pixels_per_unit))
	return moment * 4


def StraightMoment(outside, thickness, pixels_per_unit):
	step_size = 1.0/pixels_per_unit
	step_weight = 1.0/pixels_per_unit**2
	r = thickness * 2
	d_o = outside / 2
	d_m = d_o - thickness
	d_i = d_o - r

	x_min = d_i
	x_max = d_o

	moment = 0.0

	image, pixels = MakeImage(d_o, pixels_per_unit)
	
	for x in numpy.arange(x_min, x_max, step_size):
		y_min = 0
		if x < d_m:
			y_min = d_i
		y_max = x
		
		for y in numpy.arange(y_min, y_max, step_size):
			point_inside = False
			if y > d_i:
				dist = (x - d_i)**2 + (y - d_i)**2
				if dist <= r**2:
					point_inside = True
			else:
				point_inside = True

			#pixels[int(x/step_size), int(y/step_size)] = 0x000000AA
			if point_inside:
				moment = moment + (y**2 + x**2) * step_weight
				PlotPixels(image, pixels, x, y, pixels_per_unit)

	image.save("moment_straight.png", dpi=(pixels_per_unit, pixels_per_unit))
	return moment * 4

args = (10, 1.5, 100)
#print "diagonal moment: {}".format(DiagonalMoment(*args))
start = time.clock()
print "straight moment: {}".format(StraightMoment(*args))
print "time: {}".format(time.clock() - start)