module SVG
  class PathBuilder
    def initialize(parent, options = {}, &block)
      @options = options
      @commands = []
      @transform = parent.absolute_transform
      @parent = parent
      @absolute = true

      if block_given?
        block.yield(self)
        finish
      end
    end

    def finish
      @commands << "z" if @options.delete(:closed) != false
      command_string = @commands.join(" ")
      @parent.path(command_string, @options)
    end

    def absolute
      @absolute = true
    end

    def relative
      @absolute = false
    end

    def move(vector)
      add_command(:m, vector)
    end

    def line(vector)
      add_command(:l, vector)
    end

    def arc(vector, radius, rotation = 0, sweep = true, clockwise = true)
      radius = Vector2.new(radius, radius) if Numeric === radius
      radius = scale(radius)
      add_command(:a, radius.x, radius.y, rotation, bool(sweep), bool(clockwise), vector)
    end

    def cubic(vector, control1, control2)
      add_command(:c, control1, control2, vector)
    end

    def smooth_cubic(vector, control2)
      add_command(:s, control2, vector)
    end

    def quadratic(vector, control)
      add_command(:q, control, vector)
    end

    def smooth_quadratic(vector)
      add_command(:t, vector)
    end

    private

    def scale(vector)
      vector.componentwise_scale(@transform.scale)
    end

    def add_command(letter, *args)
      code = @absolute ? letter.to_s.upcase : letter.to_s.downcase
      args = args.map{ |arg| Vector2 === arg ? @transform * arg : arg }.join(" ")
      @commands << "#{code} #{args}"
    end

    def bool(value)
      value ? 1 : 0
    end

  end
end