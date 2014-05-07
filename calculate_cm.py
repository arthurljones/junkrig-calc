#!/usr/bin/python

from PIL import Image
import sys, math

class CMCalculator:
	def findCenterOfMass(self, pixels_per_inch):
		columns = {}
		sum = 0
		for i in range(0, self.iSize):		
			pixelCount = 0
			for j in range(0,  self.jSize):
				if self.pixel(i, j)[3] > 0:
					pixelCount = pixelCount + 1
			sum = sum + pixelCount
			columns[i] = (pixelCount, sum)
			
		print self.iSize, self.jSize

		center = -1
		reverseSum = 0
		total = sum
		bestDist = float("inf")
		for i in range(self.iSize - 1, -1, -1):
			count = columns[i][0]
			sum = columns[i][1]
			reverseSum = reverseSum + count
			
			dist = math.fabs(sum - reverseSum)
			if (dist < bestDist):
				bestDist = dist
				center = i
				
			#print (i, columns[i][0], sum, reverseSum, dist, bestDist)

		print("{} center: {} in".format(self.description(), float(center) / pixels_per_inch))
		print("area: {} in^2".format(float(total) / (pixels_per_inch**2)))

		return center

	def findMoment(self, cm, pixels_per_inch):
		moment = 0
		for i in range(0, self.iSize):
			distance = float(i - cm) / pixels_per_inch
			weight = distance**2
			for j in range(0,  self.jSize):
				if self.pixel(i, j)[3] == 255:
					moment += weight

		moment = moment / pixels_per_inch**2

		print("{} moment: {} in^4".format(self.description(), moment))
		return moment


class ByX(CMCalculator):
	def __init__(self, image, pixels):
		self.pixels = pixels
		self.iSize = image.size[0]
		self.jSize = image.size[1]

	def pixel(self, i, j):
		return pixels[i, j]

	def description(self):
		return "x"

class ByY(CMCalculator):
	def __init__(self, image, pixels):
		self.pixels = pixels
		self.iSize = image.size[1]
		self.jSize = image.size[0]

	def pixel(self, i, j):
		return pixels[j, i]

	def description(self):
		return "y"

image = Image.open(sys.argv[1])
pixels = image.load()

pixels_per_inch = 10
if len(sys.argv) >= 3:
	pixels_per_inch = float(sys.argv[2])

width = image.size[0]
height = image.size[1]

print "image size: {}x{} in".format(float(width)/pixels_per_inch, float(height)/pixels_per_inch)

ByX(image, pixels).findCenterOfMass(10)

#y_center = ByY(image, pixels).findCenterOfMass(pixels_per_inch)
#ByY(image, pixels).findMoment(y_center, pixels_per_inch)
