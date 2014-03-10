import sys

from math import *
from copy import *
import itertools

scarf_length = 18 #inches
count_weight = scarf_length
max_swaps = 100

def flatten(nested_iterable):
	return [x for x in itertools.chain.from_iterable(nested_iterable)]

class Piece:
	def __init__(self, length, double_scarfed = False):
		self.unscarfed_length = length
		self.length = length - scarf_length
		self.double_scarfed = double_scarfed
		self.repr_string = "{}in".format(self.unscarfed_length)
		if double_scarfed:
			self.repr_string += "-D"

	def __repr__(self):
		return self.repr_string

	@classmethod
	def init_many(cls, lengths, double_scarfed = False):
		return [cls(length, double_scarfed) for length in lengths]

	def transfer(self, old, new):
		old.pieces.remove(self)
		new.pieces.append(self)

class PieceSet:
	def __init__(self, pieces, owner):
		self.pieces = pieces
		self.owner = owner
		self.length = sum([piece.length for piece in pieces])
		self.double_scarfs = sum([piece.double_scarfed for piece in pieces])
		self.count = len(pieces)
		self.repr_string = ", ".join([str(piece) for piece in self.pieces])

	def swap(self, other):
		self_owner = self.owner
		other_owner = other.owner

		for piece in self.pieces: piece.transfer(self_owner, other_owner)
		for piece in other.pieces: piece.transfer(other_owner, self_owner)

		other.owner = self_owner
		self.owner = other_owner

		self.owner.recalculate()
		other.owner.recalculate()

	def __repr__(self):
		return self.repr_string

class Stave:
	def __init__(self, desired_length):
		self.desired_unscarfed_length = desired_length
		self.desired_length = desired_length - scarf_length
		self.pieces = []
		self.recalculate()

	def recalculate(self):
		self.piece_count = len(self.pieces)
		self.pieces_string = self.repr_string = ", ".join([str(piece) for piece in self.pieces])
		self.actual_length = sum([piece.length for piece in self.pieces])
		self.actual_unscarfed_length = self.actual_length + scarf_length * self.piece_count
		self.extra_length = self.actual_length - self.desired_length
		self.double_scarfed_pieces = sum([piece.double_scarfed for piece in self.pieces])
		self.double_scarf_capacity = self.piece_count - (2 + self.double_scarfed_pieces)
		self.repr_string = "{}{:+}in ({}) Stave".format(self.desired_length, self.extra_length, self.piece_count)

		num_pieces = self.piece_count
		self.swap_sets = []
		for index1 in xrange(num_pieces):
			piece1 = self.pieces[index1]
			self.swap_sets.append(PieceSet([piece1], self))
			for index2 in xrange(index1 + 1, num_pieces):
				piece2 = self.pieces[index2]
				self.swap_sets.append(PieceSet([piece1, piece2], self))

	def __repr__(self):
		return self.repr_string

	@classmethod
	def init_many(cls, lengths):
		return [cls(length) for length in lengths]

class WoodPile(Stave):
	def __init__(self, piece_lengths, double_scarfed_lengths):
		self.desired_length = 0
		self.pieces = Piece.init_many(piece_lengths)
		self.pieces += Piece.init_many(double_scarfed_lengths, True)
		self.desired_unscarfed_length = -scarf_length

	def __repr__(self):
		return "Wood Pile"

	def recalculate(self):
		Stave.recalculate(self)
		self.extra_length = 0

	def swap_delta(self, old, new):
		return 0

	def longest_first(self):
		self.pieces.sort(key = lambda piece: -piece.length)

	def shortest_first(self):
		self.pieces.sort(key = lambda piece: piece.length)

class StaveBuilder:
	def __init__(self, stave_lengths, piece_lengths, double_scarfed_lengths):
		self.staves = Stave.init_many(sorted(stave_lengths))
		self.wood_pile = WoodPile(piece_lengths, double_scarfed_lengths)
		self.each_piece_to_smallest_fit()
		self.swap_to_minimize_waste()
		self.wood_pile.shortest_first()

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
		return sum(stave.extra_length for stave in self.staves)

	def print_data(self):
		stave_count = self.stave_count
		overflow = self.total_overflow
		total_pieces = self.stave_pieces_count
		total_used_length = sum(stave.actual_unscarfed_length for stave in self.staves)
		scarf_example_length = max(stave.desired_length for stave in self.staves)

		pieces_used = sorted([piece for piece in itertools.chain.from_iterable([stave.pieces for stave in self.staves])], key=lambda piece: piece.length)

		print "{} Pieces, {} Staves:".format(self.total_pieces_count, self.stave_count)
		for stave in self.staves:
			print "{}{:+}in:\t{}".format(stave.desired_unscarfed_length, stave.extra_length, stave.pieces_string)
		print "Total extra length: {}in".format(overflow)
		print "Average extra length: {:.1f}in".format(float(overflow)/stave_count)
		print "Total pieces used: {}".format(total_pieces)
		print "Average pieces per stave: {:.1f}".format(float(total_pieces)/stave_count)
		print "Average pieces per {:.1f}ft: {:.1f}".format(float(scarf_example_length) / 12, scarf_example_length / (float(total_used_length) / total_pieces))
		print "Unused Length: {}in".format(self.wood_pile.actual_unscarfed_length)
		print "{} Pieces Unused: {}".format(self.wood_pile.piece_count, self.wood_pile.pieces_string)
		print "{} Pieces Used: {}".format(len(pieces_used), pieces_used)

		print factor_list([piece.unscarfed_length for piece in self.wood_pile.pieces])

	def each_piece_to_smallest_fit(self):
		self.wood_pile.longest_first()
	 	self.build_by_delta(lambda piece: 0)
		self.wood_pile.shortest_first()
	 	self.build_by_delta(lambda piece: piece.length)

	def swap_to_minimize_waste(self):
		for iteration in xrange(max_swaps):
			print "Iteration {}:".format(iteration + 1)
			if self.wood_pile.piece_count == 0:
				overlong_stave = max(self.staves, key = lambda stave: stave.extra_length)
				shortest_piece = min(overlong_stave.pieces, key = lambda piece: piece.length)
				active = PieceSet([shortest_piece], overlong_stave)
				passive = PieceSet([], self.wood_pile)
				passive.swap(active)
				print "\tWood pile starved - moving shortest piece of most overlong board".format(iteration + 1)
			else:
				if self.perform_best_swap() is None:
					print "\tNo more improvement"
					return

		print "Reached iteration limit"

	def perform_best_swap(self):
		#Each swap can only have passive pieces on one side and active pieces on the other
		#Swaps can only happen between the wood pile and a single stave

		active_sets = flatten([stave.swap_sets for stave in self.staves])
		passive_sets = self.wood_pile.swap_sets

		best_swap_score = 0
		best_passive = None
		best_active = None

		for passive in passive_sets:
			for active in active_sets:
				swap_score = self.swap_score(passive, active)
				#print "Swap score: {}".format(swap_score)
				if swap_score and swap_score < best_swap_score:
					best_passive = passive
					best_active = active
					best_swap_score = swap_score

		if best_swap_score < 0:
			#print "Swapping ({}) {} {} with {} {}".format(best_swap_score, best_passive.owner, best_passive.pieces, best_active.owner, best_active.pieces)
			print "\t({}): {} -> {} -> {}".format(best_swap_score, best_passive, best_active.owner, best_active)

			best_passive.swap(best_active)
			return best_swap_score
		else:
			return None

	def swap_score(self, passive, active):
		extra = active.owner.extra_length
		delta = passive.length - active.length
		double_scarf_delta = passive.double_scarfs - active.double_scarfs

		if double_scarf_delta > active.owner.double_scarf_capacity:
			return None
		elif extra < 0:
			return -(extra + delta)
		elif extra + delta < 0:
			return None
		else:
			count_change = passive.count - active.count
			return delta + count_change * count_weight


	def build_by_delta(self, max_delta_func):
		while len(self.wood_pile.pieces) > 0:
			piece = self.wood_pile.pieces[0]
			best_delta = max_delta_func(piece)
			target_stave = None
			for stave in self.staves:
				delta = stave.extra_length + piece.length
				if delta < best_delta:
					best_length = delta
					target_stave = stave

			if target_stave == None:
				break
			else:
				piece.transfer(self.wood_pile, target_stave)
				target_stave.recalculate()

		self.wood_pile.recalculate()

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

	return " + \\\n".join(["[{}]*{}".format(",".join([str(length) for length in sorted(lengths)]), count) for count, lengths in count_lengths.iteritems()])

piece_lengths = [50, 57, 57, 57, 58, 58, 59, 60, 60, 60, 60, 60, 60, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 63, 64, 64, 64, 64, 64, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 70, 71, 73, 73, 73, 74, 75, 75, 75, 75, 75, 75, 75, 76, 76, 76, 76, 78, 78, 79, 79, 79, 79, 80, 80, 81, 81, 81, 81, 81, 82, 83, 83, 83, 84, 85, 86, 86, 86, 86, 87, 87, 88, 88, 88, 89, 89, 89, 89, 89, 89, 91, 91, 91, 93, 95, 95, 96, 96, 96, 96, 97, 97, 97, 97, 99, 99, 99, 100, 100, 100, 100, 101, 103, 109, 115, 116, 116, 117, 118, 118, 119, 120, 122, 123, 128, 128, 128, 134, 135, 136, 137, 138, 141, 142, 150, 151, 154, 155, 157, 157, 158, 160, 161, 162, 178, 192, 192, 214, 241, 241, 241, 241]
double_scarfed_lengths = [96, 117, 132, 59, 65, 65, 76, 79]
piece_lengths.sort()
stave_lengths = [405] * 32

#stave_lengths = [165] * 8 + [288] * 8 + [403] * 24

builder = StaveBuilder(stave_lengths, piece_lengths, double_scarfed_lengths)
builder.print_data()


