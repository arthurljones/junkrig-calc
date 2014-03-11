module Mast
  class StaveBuilder
    COUNT_WEIGHT = SCARF_LENGTH

    attr_reader :staves, :wood_pile, :max_swaps

    def initialize(stave_lengths, single_scarf_lengths, double_scarf_lengths, max_swaps, extra_stave_length)
      lengths = stave_lengths.map{|length| length + extra_stave_length}.sort
      @staves = stave_lengths.collect{ |length| Stave.new(length) }
      @wood_pile = WoodPile.new
      @max_swaps = max_swaps

      extras = initial_distribution(single_scarf_lengths, double_scarf_lengths)
      wood_pile.add(extras)
      swap_to_minimize_waste
    end

    def print_data
      stave_count = staves.size
      overflow = staves.sum(&:extra_length)
      pieces_used = staves.collect{|stave| stave.pieces.to_a}.flatten.sort_by(&:length)
      pieces_used_count = pieces_used.count
      total_pieces = wood_pile.pieces.count + pieces_used_count
      total_used_length = staves.sum(&:actual_unscarfed_length)
      scarf_example_length = staves.sum(&:desired_length)
      total_scarfs = total_pieces - stave_count
      total_scarf_cuts = total_scarfs * 2
      scarf_cuts_remaining = total_scarf_cuts - total_pieces - staves.sum(&:double_scarfed_pieces)

      puts "#{total_pieces} Pieces, #{stave_count} Staves:"
      staves.each { |stave| puts stave }
      puts "Total used length: #{total_used_length}in"
      puts "Total extra length: #{overflow}in"
      puts "Average extra length: #{"%.1f" % (overflow / stave_count)}in"
      puts "Total pieces used: #{total_pieces}"
      puts "Average pieces per stave: #{"%.1f" % (total_pieces / stave_count)}"
      puts "Average pieces per #{"%.1f" % (scarf_example_length / 12)}ft: #{"%.1f" % (scarf_example_length / (total_used_length / total_pieces))}"
      puts "Scarfs: Total: #{total_scarfs}, Total Cuts: #{total_scarf_cuts}, Cuts remaining: #{scarf_cuts_remaining}"
      puts "Unused Length: #{wood_pile.actual_unscarfed_length}in"
      puts "#{wood_pile.pieces.count} Pieces Unused: #{wood_pile.pieces}"
      puts "#{pieces_used_count} Pieces Used: #{pieces_used}"
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
      @max_swaps.times do |iteration|
        puts "Iteration #{iteration + 1}:"
        if wood_pile.pieces.count == 0
          overlong_stave = staves.max_by(&:extra_length)
          puts overlong_stave
          shortest_piece = overlong_stave.pieces.min_by(&:length)
          active = SwapSet.new([shortest_piece], overlong_stave)
          passive = SwapSet.new([], wood_pile)
          passive.swap(active)
          puts "\tWood pile starved - moving shortest piece of most overlong board"
        else
          if perform_best_swap == nil
            puts "\tNo more improvement"
            return
          end
        end
      end

      puts "Reached iteration limit"
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
      extra = active.owner.extra_length
      delta = passive.length - active.length
      double_scarf_delta = passive.double_scarfed_pieces - active.double_scarfed_pieces

      if double_scarf_delta > active.owner.double_scarf_capacity
        nil
      elsif extra < 0
        -(extra + delta)
      elsif extra + delta < 0
        nil
      else
        count_change = passive.pieces.count - active.pieces.count
        delta + count_change * COUNT_WEIGHT
      end
    end

    def distribute_by_shortest_staves(pieces, &worst_case)
      while pieces.any?
        piece = pieces.first
        best_new_extra = worst_case.call(piece)
        target_stave = nil
        staves.each do |stave|
          new_extra = stave.extra_length + piece.length
          if new_extra < best_new_extra && (stave.double_scarf_capacity > 0 || !piece.double_scarfed)
            best_new_extra = new_extra
            target_stave = stave
          end
        end

        if target_stave
          pieces.shift
          puts "Adding #{piece} to #{target_stave}"
          target_stave.add([piece])
        else
          break
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