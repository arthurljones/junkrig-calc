class BoxSectionMast(object):
	def Moment(outside, thickness, angle, samples_per_inch = 15, make_image = False):
		sin_t = sin(radians(angle))
		cos_t = cos(radians(angle))

		outside = float(outside)
		thickness = float(thickness)
		angle = float(angle)

		cos_45 = 0.70710678118
		step_size = 1.0/samples_per_inch
		r = thickness * 2
		d_o = outside / 2
		d_m = d_o - thickness
		d_i = d_o - r

		bounds = outside * cos_45

		r_squared = r**2
		
		moment = 0
		points = []

		if make_image:
			image, pixels = MakeImage(bounds * 2 * samples_per_inch)

		max_y = 0

		for x in np.arange(-bounds, bounds, step_size):
			for y in np.arange(-bounds, bounds, step_size):

				tx = x*cos_t - y*sin_t
				ty = x*sin_t + y*cos_t

				color = 0xAA000000
				if tx < 0 and ty < 0:
					tx, ty = -tx, -ty
					color = 0xAAFF0000
				elif tx < 0:
					tx, ty = ty, -tx
					color = 0xAA00FF00
				elif ty < 0:
					tx, ty = -ty, tx
					color = 0xAA0000FF

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
					pixels[(x + bounds) * pixels_per_unit, (y + bounds) * pixels_per_unit] = color

					adjusted_y = y + step_size
					if adjusted_y > max_y:
						max_y = adjusted_y

					moment += y * y

		moment /= pixels_per_unit * pixels_per_unit
		image.transpose(Image.FLIP_TOP_BOTTOM).save("mast_x_section_%02d_deg.png" % angle, dpi=(pixels_per_unit, pixels_per_unit))

		return [moment, max_y, moment / max_y]