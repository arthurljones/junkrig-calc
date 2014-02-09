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

def factor_list(items):
	length_counts = {}
	for length in items:
		if length in length_counts:
			length_counts[length] += 1
		else:
			length_counts[length] = 1

	count_lengths = {}
	for length, count in length_counts.iteritems():
		if not count in count_lengths:
			count_lengths[count] = []

		count_lengths[count].append(length)

	return " +\n".join(["[{}]*{}".format(",".join([str(length) for length in sorted(lengths)]), count) for count, lengths in count_lengths.iteritems()])

piece_lengths = \
	[68,78,85,91,95,102,103,104,116,117,118,120,121,123,128,129,132,135,138,153,158,161,162,177,187,214,220] * 1 + \
	[61,64,70,71,73,75,124,134,136,156,174,176] * 2 + \
	[60,63,65,83,84,86] * 3 + \
	[88,97,145,240] * 4 + \
	[62,133] * 6 + \
	[67,96,192] * 7 + \
	[76,89] * 8 + \
	[66] * 9 + \
	[100] * 10 + \
	[82] * 11

piece_lengths.sort()
stave_lengths = [166] * 8 + [291] * 8 + [409] * 24

builder = StaveBuilder(stave_lengths, piece_lengths)
builder.print_data()
