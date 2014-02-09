import sys

from math import *
from copy import *
import itertools

scarf_length = 18
count_weight = 0.5

def flatten(nested_iterable):
	return [x for x in itertools.chain.from_iterable(nested_iterable)]

class Piece:
	def __init__(self, length):
		self.length = length - scarf_length

	def __repr__(self):
		return "{}in Piece".format(self.length)

	@classmethod
	def init_many(cls, lengths):
		return [cls(length) for length in lengths]

	def transfer(self, old, new):
		old.pieces.remove(self)
		new.pieces.append(self)

	@property
	def unscarfed_length(self):
		return self.length + scarf_length

class PieceSet:
	def __init__(self, pieces, owner):
		self.pieces = pieces
		self.owner = owner
		self.length = sum([piece.length for piece in pieces])
		self.count = len(pieces)

	def swap(self, other):
		self_owner = self.owner
		other_owner = other.owner

		for piece in self.pieces: piece.transfer(self_owner, other_owner)
		for piece in other.pieces: piece.transfer(other_owner, self_owner)

		other.owner = self_owner
		self.owner = other_owner

	def woodpile_swap_score(self, other):
		self_new_delta = self.owner.swap_delta(self, other)
		other_new_delta = other.owner.swap_delta(other, self)

		if self_new_delta == None or other_new_delta == None:
			return None
		else:
			return self_new_delta + other_new_delta + (

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
	def actual_unscarfed_length(self):
		return self.actual_length + scarf_length * self.piece_count

	@property
	def actual_length(self):
		return sum(piece.length for piece in self.pieces)

	@property
	def length_delta(self):
		return self.actual_length - self.desired_length

	@property
	def swap_sets(self):
		num_pieces = self.piece_count
		sets = []
		for index1 in xrange(num_pieces):
			piece1 = self.pieces[index1]
			sets.append(PieceSet([piece1], self))
			for index2 in xrange(index1 + 1, num_pieces):
				piece2 = self.pieces[index2]
				sets.append(PieceSet([piece1, piece2], self))
		return sets

	def swap_delta(self, old, new):
		delta = new.length - old.length
		if self.actual_length + delta < self.desired_length:
			return None
		else:
			return delta

class WoodPile(Stave):
	def __init__(self, piece_lengths):
		self.desired_length = 0
		self.pieces = Piece.init_many(piece_lengths)

	def __repr__(self):
		return "Wood Pile"

	def swap_delta(self, old, new):
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
		print "Stave Builder"
		self.staves = Stave.init_many(sorted(stave_lengths))
		self.wood_pile = WoodPile(piece_lengths)
		self.each_piece_to_smallest_fit()
		self.swap_to_even_out()

	@property
	def stave_count(self):
		return len(self.staves)

	@property
	def stave_pieces_count(self):
		 return sum(stave.piece_count for stave in self.staves)

	@property
	def total_pieces_count(self):
		return len(self.wood_pile.pieces) + self.stave_pieces_count

	@property
	def total_overflow(self):
		return sum(stave.length_delta for stave in self.staves)

	def print_data(self):
		stave_count = self.stave_count
		overflow = self.total_overflow
		total_pieces = self.stave_pieces_count

		print "{} Pieces, {} Staves:".format(self.total_pieces_count, self.stave_count)
		for stave in self.staves:
			print "{}{:+}in:\t{}".format(stave.desired_unscarfed_length, stave.length_delta, stave.pieces_string)
		print "Total extra length: {}in, Average extra length: {:.1f}in".format(overflow, float(overflow)/stave_count)
		print "Total pieces used: {}, Average pieces per stave: {:.2f}".format(total_pieces, float(total_pieces)/stave_count)
		print "{}in / {} Pieces Unused: {}".format(self.wood_pile.actual_unscarfed_length, self.wood_pile.piece_count, self.wood_pile.pieces_string)

	def each_piece_to_smallest_fit(self):
		self.wood_pile.longest_first()
	 	self.build_by_delta(lambda piece: 0)
		self.wood_pile.shortest_first()
	 	self.build_by_delta(lambda piece: piece.length)

	def perform_best_swap(self):
		active_sets = flatten([stave.swap_sets for stave in self.staves])
		passive_sets = self.wood_pile.swap_sets

		#Each swap can only have passive pieces on one side and active pieces on the other
		#Swaps can only happen between the wood pile and a single stave

		best_swap_score = 0
		swap1 = None
		swap2 = None

		for passive in passive_sets:
			for active in active_sets:
				swap_score = passive.swap_score(active)
				#print "Swap score: {}".format(swap_score)
				if swap_score and swap_score < best_swap_score:
					swap1 = passive
					swap2 = active
					best_swap_score = swap_score

		if swap1:
			print "Swapping ({}) {} {} with {} {}".format(best_swap_score, swap1.owner, swap1.pieces, swap2.owner, swap2.pieces)
			swap1.swap(swap2)
			return True
		else:
			return False


	def swap_to_even_out(self):
		for iteration in xrange(50):
			if self.perform_best_swap() == False:
				break

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
				piece.transfer(self.wood_pile, target_stave)

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
