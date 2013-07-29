from math import *
import time
import numpy as np
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

def Moment(outside, thickness, angle, pixels_per_unit):
	sin_t = sin(radians(angle))
	cos_t = cos(radians(angle))

	cos_45 = 0.70710678118
	step_size = 1.0/pixels_per_unit
	r = thickness * 2
	d_o = outside / 2
	d_m = d_o - thickness
	d_i = d_o - r

	bounds = outside * cos_45

	r_squared = r**2
	
	moment = 0
	points = []

	for x in np.arange(-bounds, bounds, step_size):
		for y in np.arange(-bounds, bounds, step_size):

			tx = x*cos_t - y*sin_t
			ty = x*sin_t + y*cos_t

			if tx < 0 and ty < 0:
				tx, ty = -tx, -ty
				ty = -ty
			elif tx < 0:
				tx, ty = ty, -tx
			elif ty < 0:
				tx, ty = -ty, tx

			point_inside = False
			if tx < d_i:
				point_inside = (d_m <= ty <= d_o)
			elif ty < d_i:
				point_inside = (d_m <= tx <= d_o)
			else:
				dx = tx - d_i
				dy = ty - d_i
				point_inside = dx*dx + dy*dy <= r_squared

			if point_inside:
				moment += y * y

	moment /= pixels_per_unit * pixels_per_unit

	return moment

def StraightMoment(outside, thickness, pixels_per_unit):
	return Moment(outside, thickness, 0, pixels_per_unit)

outside = 10
thickness = 1.5
ppu = 30

#print "diagonal moment: {}".format(DiagonalMoment(*args))
start = time.clock()
for angle in range(0, 91, 5):
	print angle, Moment(outside, thickness, angle, ppu)
