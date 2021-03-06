require_relative 'mast'
require_relative 'wood_pile'

module Mast
  class StaveBuilder
    COUNT_WEIGHT = SCARF_LENGTH
    STARVATION_LIMIT = 4

    attr_reader :staves, :wood_pile, :max_swaps

    def initialize(staves, single_scarf_lengths, double_scarf_lengths, max_swaps)
      @staves = staves
      @max_swaps = max_swaps

      ap "init"
      extras = initial_distribution(single_scarf_lengths, double_scarf_lengths)
      ap "extras #{extras.size}"
      @wood_pile = WoodPile.new(extras)
      ap "swapping"
      swap_to_minimize_waste
      ap "done"
    end

    def print_data
      stave_count = staves.size
      overflow = staves.sum(&:extra_length)
      pieces_used = staves.collect{|stave| stave.pieces.to_a}.flatten.sort_by(&:length)
      total_pieces_used = pieces_used.count
      total_pieces = wood_pile.pieces.count + total_pieces_used
      total_used_length = staves.sum(&:actual_unscarfed_length)
      scarf_example_length = staves.sum(&:desired_length) / stave_count
      total_scarfs = total_pieces_used - stave_count
      total_scarf_cuts = total_scarfs * 2
      scarf_cuts_remaining = total_scarf_cuts - total_pieces_used - staves.sum(&:double_scarfed_pieces)

      puts "#{total_pieces} Pieces, #{stave_count} Staves:"
      staves.each { |stave| puts stave }
      puts "#{total_pieces_used} Pieces Used: #{pieces_used}"
      puts "#{wood_pile.count} Pieces Unused: #{wood_pile.pieces}"
      puts "Total used length: #{total_used_length}in"
      puts "Total extra length: #{overflow}in"
      puts "Average extra length: #{"%.1f" % (overflow / stave_count)}in"
      puts "Average pieces per stave: #{"%.1f" % (total_pieces_used / stave_count)}"
      puts "Average pieces per #{"%.1f" % (scarf_example_length / 12)}ft: #{"%.1f" % (scarf_example_length / (total_used_length / total_pieces_used))}"
      puts "Scarfs: Total: #{total_scarfs}, Total Cuts: #{total_scarf_cuts}, Cuts remaining: #{scarf_cuts_remaining}"
      puts "Unused Length: #{wood_pile.actual_unscarfed_length}in"

      if overflow < 0
        shortage_ft = -overflow / 12
        useful_ratio = 0.65
        price_per_ft = 0.6
        staves_per_board = 3
        board_length_ft = 16
        required_ft = shortage_ft / useful_ratio / staves_per_board
        required_boards = (required_ft / board_length_ft).ceil
        price = required_boards * board_length_ft * price_per_ft

        puts "Lumber Shortage: #{"%.1f" % shortage_ft}ft"
        puts "Required lumber with #{((1 - useful_ratio) * 100).to_i}% waste: #{"%.1f" % required_ft}ft"
        puts "Required #{board_length_ft}ft boards: #{required_boards}"
        puts "Total lumber cost at $#{"%.2f" % price_per_ft}: $#{"%.2f" % price}"
      end
    end

    def initial_distribution(single_scarf_lengths, double_scarf_lengths)
      #Allocate single-scarfed pieces to the most needful staves first without going over the stave's length, longest pieces first
      unallocated = LumberPiece.init_many(single_scarf_lengths)
      unallocated.sort!.reverse!
      distribute_by_shortest_staves(unallocated) {0}

      #Add in double-scarfed pieces and allocate again, same algorithm
      unallocated += LumberPiece.init_many(double_scarf_lengths, true) #Add in double scarfed staves
      unallocated.sort!.reverse! #Longest first
      distribute_by_shortest_staves(unallocated) {0} #Only add to staves where we won't go over

      #Allocate all pieces to the most needful staves first, this time allowing extra stave length up to the piece length
      unallocated.sort! #Shortest first
      distribute_by_shortest_staves(unallocated) { |piece| piece.length } #Don't add pieces to already-full staves

      #Return unused pieces
      unallocated
    end

    def swap_to_minimize_waste
      starvations = 0
      @max_swaps.times do |iteration|
        puts "Iteration #{iteration + 1}:"
        if wood_pile.count == 0
          if starvations >= STARVATION_LIMIT
            puts "\tStarvation limit reached"
            return
          else
            starvations += 1
            overlong_stave = staves.max_by(&:extra_length)
            shortest_piece = overlong_stave.pieces.reject(&:locked?).min_by(&:length)
            active = SwapSet.new([shortest_piece], overlong_stave)
            passive = SwapSet.new([], wood_pile)
            passive.swap(active)
            puts "\tWood pile starved - pulling shortest piece of board with most extra length"
            puts "\t#{overlong_stave} -> #{shortest_piece}"
          end
        else
          if perform_best_swap == nil
            puts "\tNo more improvement"
            return
          end
        end
      end

      puts "Iteration limit reached"
    end

    def perform_best_swap
      #Each swap can only have passive pieces on one side and active pieces on the other
      #Swaps can only happen between the wood pile and a single stave

      active_sets = staves.collect(&:unique_swap_sets).flatten #TODO: Could be optimized into a central pool
      passive_sets = wood_pile.unique_swap_sets

      best_swap_score = 0
      best_passive = nil
      best_active = nil

      passive_sets.to_a.product(active_sets) do |passive, active|
        swap_score = swap_score(passive, active)
        #puts "Swap score: #{swap_score}"
        if swap_score && swap_score < best_swap_score
          best_passive = passive
          best_active = active
          best_swap_score = swap_score
        end
      end

      if best_swap_score < 0
        puts "\t(#{best_swap_score}) #{best_passive} -> #{best_active.owner} -> #{best_active}"

        best_passive.swap(best_active)
        best_swap_score
      else
        nil
      end
    end

    def swap_score(passive, active)
      return nil if active.count + passive.count == 0
      return nil if active.pieces.any?(&:locked?) || passive.pieces.any?(&:locked?)

      current = active.owner
      result = active.test_swap(passive)

      extra = current.extra_length
      delta = result.length - current.length
      count_delta = result.count - current.count

      current_double_extra = [current.double_scarf_extra, 0].max
      result_double_extra = [result.double_scarf_extra, 0].max
      double_extra_delta = result_double_extra - current_double_extra

      if extra < 0
        if delta > 0
          if delta < -extra
            -delta
          else
            extra / delta
          end
        else
          nil
        end
      elsif extra + delta < 0
        nil
      else
        delta + count_delta * COUNT_WEIGHT + double_extra_delta * SCARF_LENGTH
      end
    end

    def distribute_by_shortest_staves(pieces, &worst_case)
      pieces.delete_if do |piece|
        best_new_extra = worst_case.call(piece)
        target_stave = nil
        staves.each do |stave|
          new_extra = stave.extra_length + piece.length
          if new_extra < best_new_extra# && (stave.double_scarf_capacity > 0 || !piece.double_scarfed)
            best_new_extra = new_extra
            target_stave = stave
          end
        end

        if target_stave
          target_stave << [piece]
          true
        else
          false
        end
      end
    end

    def factor_list(values)
      groups = Hash.new(0)
      values.each { |value| groups[values] += 1 }
      groups.inject({}) { |memo, (value, count)| (memo[count] ||= Set.new) << value; memo }
      #return " + \\\n".join(["[{}]*{}".format(",".join([str(length) for length in sorted(lengths)]), count) for count, lengths in count_lengths.iteritems])
    end
  end
end
