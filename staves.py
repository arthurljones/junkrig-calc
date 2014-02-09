import sys

from math import *
from copy import *

scarf_length = 18

class Piece:
	def __init__(self, length):
		self.length = length - scarf_length
		self.owner = None

	def __repr__(self):
		return "{}in Piece".format(self.length)

	@classmethod
	def init_many(cls, lengths):
		return [cls(length) for length in lengths]

	def index(self):
		if self.owner != None:
			index = self.owner.pieces.index(self)
			if index < 0:
				raise LookupError("Cannot find stave piece in this stave")
			return index
		else:
			return None

	def swap(self, other):
		own_index = self.index()
		other_index = other.index()
		own_owner = self.owner
		other_owner = other.owner

		self.owner = other_owner
		other.owner = own_owner

		own_owner.pieces[own_index] = other
		other_owner.pieces[other_index] = self

	def swap_value(self, other):
		self_new_delta = self.owner.swap_delta(self, other)
		other_new_delta = other.owner.swap_delta(other, self)

		if self_new_delta < 0 or other_new_delta < 0:
			return None
		else:
			return self_new_delta + other_new_delta

	@property
	def unscarfed_length(self):
		return self.length + scarf_length

class Stave:
	def __init__(self, desired_length):
		self.desired_length = desired_length - scarf_length
		self.pieces = []

	def __repr__(self):
		return "{}{:+}in ({}) Stave".format(self.desired_length, self.length_delta, len(self.pieces))

	@classmethod
	def init_many(cls, lengths):
		return [cls(length) for length in lengths]

	@property
	def piece_count(self):
		return len(self.pieces)

	@property	
	def pieces_string(self):
		return ", ".join(["{}in".format(piece.unscarfed_length) for piece in self.pieces])

	@property
	def desired_unscarfed_length(self):
		return self.desired_length + scarf_length

	@property
	def actual_length(self):
		return sum(piece.length for piece in self.pieces)

	@property
	def length_delta(self):
		return self.actual_length - self.desired_length

	def swap_delta(old, new):
		return length_delta + new.length - old.length

	def similarity(self, other):
		return 0 #TODO

	def push(self, piece):
		piece.owner = self
		self.pieces.append(piece)

class WoodPile(Stave):
	def __init__(self, piece_lengths):
		self.desired_length = 0
		self.pieces = Piece.init_many(piece_lengths)

	def __repr__(self):
		return "Wood Pile"

	def swap_delta(self):
		return 0

	def longest_first(self):
		self.pieces.sort(key = lambda piece: -piece.length)

	def shortest_first(self):
		self.pieces.sort(key = lambda piece: piece.length)

	@property
	def desired_unscarfed_length(self):
		return -scarf_length

	@property
	def length_delta(self):
		return 0

class StaveBuilder:
	def __init__(self, stave_lengths, piece_lengths):
		self.staves = Stave.init_many(sorted(stave_lengths))
		self.wood_pile = WoodPile(piece_lengths)
		self.all_pieces = copy(self.wood_pile.pieces)
		self.each_piece_to_smallest_fit()

	@property
	def stave_count(self):
		return len(self.staves)

	@property
	def stave_pieces_count(self):
		 return sum(stave.piece_count for stave in self.staves)

	@property
	def total_overflow(self):
		return sum(stave.length_delta for stave in self.staves)


	def print_data(self):
		stave_count = self.stave_count
		overflow = self.total_overflow
		total_pieces = self.stave_pieces_count

		print "{} Pieces, {} Staves:".format(len(self.all_pieces), self.stave_count)
		for stave in self.staves:
			print "{}{:+}in:\t{}".format(stave.desired_unscarfed_length, stave.length_delta, stave.pieces_string)
		print "Total extra length: {}in, Average extra length: {:.1f}in".format(overflow, float(overflow)/stave_count)
		print "Total pieces used: {}, Average pieces per stave: {:.2f}".format(total_pieces, float(total_pieces)/stave_count)
		print "{} unused pieces: {}".format(self.wood_pile.piece_count, self.wood_pile.pieces_string)

	def each_piece_to_smallest_fit(self):
		self.wood_pile.longest_first()
	 	self.build_by_delta(lambda piece: 0)
		self.wood_pile.shortest_first()
	 	self.build_by_delta(lambda piece: piece.length)

	def each_stave_until_full(self):
		self.wood_pile.shortest_first()
		for stave in staves:
			while stave.length_delta < 0 and len(unused_pieces) > 0:
				stave.push(unused_pieces.pop(0))

	def swap_to_even_out(self):
		pass

	def build_by_delta(self, max_delta_func):
		while len(self.wood_pile.pieces) > 0:
			piece = self.wood_pile.pieces[0]
			best_delta = max_delta_func(piece)
			target_stave = None
			for stave in self.staves:
				delta = stave.length_delta + piece.length
				if delta < best_delta:
					best_length = delta
					target_stave = stave

			if target_stave == None:
				break
			else:
				target_stave.push(self.wood_pile.pieces.pop(0))

piece_lengths = [60, 60, 60, 61, 61, 62, 62, 62, 62, 62, 62, 63, 63, 63, 64, 64, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 67, 67, 67, 67, 67, 68, 70, 70, 71, 71, 73, 73, 75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 78, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 83, 83, 83, 84, 84, 84, 85, 86, 86, 86, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 89, 89, 91, 95, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 102, 103, 104, 116, 117, 118, 120, 121, 123, 124, 124, 128, 129, 132, 133, 133, 133, 133, 133, 133, 134, 134, 135, 136, 136, 138, 145, 145, 145, 145, 153, 156, 156, 158, 161, 162, 174, 174, 176, 176, 177, 187, 192, 192, 192, 192, 192, 192, 192, 214, 220, 240, 240, 240, 240]
stave_lengths = [166] * 8 + [291] * 8 + [409] * 24

builder = StaveBuilder(stave_lengths, piece_lengths)
builder.print_data()
