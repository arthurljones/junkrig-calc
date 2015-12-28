require "math/vector2"
require "sheet/anchor_point"
require "sheet/free_point"
require "sheet/segment"

class Sheet::System
  attr_reader :points, :segments

  def initialize
    @points = []
    @segments = []
  end

  def add_points(points)
    @points += Array(points)
  end

  def add_segments(segments)
    @segments += Array(segments)
  end

  def solve(max_iterations, max_stable_iterations)
    stable_iterations = 0

    (1..max_iterations).each do |iteration|
      ap "===== Step #{iteration}"

      yield(iteration, stable_iterations) if block_given?

      @segments.each(&:apply)
      stable = @points.map(&:resolve).none?

      if stable
        stable_iterations += 1
        if stable_iterations >= max_stable_iterations
          puts "Done after #{stable_iterations} stable iterations"
          break
        end
      else
        stable_iterations = 0
      end
    end
  end
end
