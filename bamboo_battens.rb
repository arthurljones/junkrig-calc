require_relative "boilerplate"
require "battens/batten_piece"
require "battens/batten_set"

def closest_piece(pieces, target)
  piece = pieces.delete(pieces.min_by { |piece| [piece.best_match_for(target), -piece.small_end] })
  piece.truncate_for(target)
  piece
end

pieces = [
  { :name => 'A', :ends => [2.5, :t, 2.375] },
  { :name => 'B', :ends => [2.375, :t, 2.75] },
  { :name => 'C', :ends => [2.625, 2.125] },
  { :name => 'D', :ends => [2.5, 2.375] },
  { :name => 'E', :ends => [1.75, 2.5] },
  { :name => 'F', :ends => [2.75, 2.125] },
  { :name => 'G', :ends => [2.5, 2.625] },
  { :name => 'H', :ends => [2.5, 2] },
  { :name => 'I', :ends => [1.75, 2.375] },
  { :name => 'J', :ends => [1.875, 2.375] },
  { :name => 'K', :ends => [2.875, :t, 2] },
  { :name => 'L', :ends => [1.5, 2.25] },
  { :name => 'M', :ends => [2, 2.5] },
  { :name => 'N', :ends => [2.25, :t, 2.25] },
  { :name => 'O', :ends => [2.5, 2] },
  { :name => 'P', :ends => [2.25, :t, 2.125] },
  { :name => 'Q', :ends => [2.125, :t, 2] },
  { :name => 'R', :ends => [2.125, 2.5, :t] },
  { :name => 'S', :ends => [1.75, 2.375] },
  { :name => 'T', :ends => [2.675, 2.5, :t] },
  { :name => 'U', :ends => [1.875, 2.5] },
  { :name => 'V', :ends => [2.125, 2.375, :t] },
  { :name => 'W', :ends => [2.125, 2.75] },
  { :name => 'X', :ends => [2.25, 2.675] },
  { :name => 'Y', :ends => [2.675, 2] }
]

batten_count = 7

pieces = pieces.map{|opts| BattenPiece.new(opts[:name], opts[:ends])}.sort_by(&:ends).last(batten_count * 21)
#puts battens
centers = pieces.sort_by(&:small_end).last(batten_count) #Biggest small ends
pieces = pieces - centers

battens = centers.map do |center|
  fore = closest_piece(pieces, center.big_end)
  aft = closest_piece(pieces, center.small_end)
  BattenSet.new(aft, center, fore)
end

puts battens
