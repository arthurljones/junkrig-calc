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

def DiagonalMoment(outside, thickness, pixels_per_unit):
	step_size = 1.0/pixels_per_unit
	cos_45 = 0.70710678118
	r = thickness * 2
	d_i = (outside - 2*r) * cos_45
	d_m = (outside - 2*thickness) * cos_45
	d_o = outside * cos_45

	x_min = d_m / 2
	x_max = d_i + r

	moment = 0.0
	
	for x in np.arange(x_min, x_max, step_size):
		y_min = 0.0
		y_max = d_o - x
		if x < y_max:
			y_max = x

		for y in np.arange(y_min, y_max, step_size):
			point_inside = False
			if y <= x - d_i:
				dist = (x - d_i)**2 + y**2
				if dist <= r**2:
					point_inside = True
			elif y >= d_m - x:
					point_inside = True
			
			if point_inside:
				moment += (y*y + x*x)

	return (moment / (pixels_per_unit * pixels_per_unit)) * 4

def Moment(outside, thickness, angle, pixels_per_unit):
	sin_t = sin(radians(angle))
	cos_t = cos(radians(angle))

	cos_45 = 0.70710678118
	step_size = 1.0/pixels_per_unit
	r = thickness * 2
	d_o = outside / 2
	d_m = d_o - thickness
	d_i = d_o - r

	x_min = 0
	x_max = outside * cos_45

	y_min = 0
	y_max = outside * cos_45

	r_squared = r**2
	
	moment = 0
	points = []

	for x in np.arange(x_min, x_max, step_size):
		for y in np.arange(y_min, y_max, step_size):

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

	return moment * 4

def StraightMoment(outside, thickness, pixels_per_unit):
	return Moment(outside, thickness, 0, pixels_per_unit)

outside = 10
thickness = 1.5
ppu = 50

#print "diagonal moment: {}".format(DiagonalMoment(*args))
start = time.clock()
moment = Moment(outside, thickness, 45, ppu)
dmoment = moment - DiagonalMoment(outside, thickness, ppu)
print dmoment
difference = moment - dmoment#560.64903168
print "straight moment: {} ({})".format(moment, difference)
print "time: {}".format(time.clock() - start)
