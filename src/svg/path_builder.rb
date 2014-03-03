module SVG
  class PathBuilder
    def initialize(parent, options = {}, &block)
      @options = options
      @commands = []
      if block_given?
        block.yield(self)
        finish
      end
    end

    def finish

    end

    def move(vector, absolute = true)

    end

    def line(vector, absolute = true)

    end

    def arc(start, stop, rotation, sweep, clockwise)

    end

  end
end