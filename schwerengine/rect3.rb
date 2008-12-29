# rect.rb
# igneus 22.2.2005

module SchwerEngine

  # Shortcut for 'Rectangle.new(x,y,w,h)'
  def R(x,y,w,h)
    Rectangle.new x,y,w,h
  end

  # Version of class Rectangle optimized by replacing dynamic computation
  # of Rectangle#right with static values

  class Rectangle

    RECTANGLE_VERSION = 3

    def initialize(*coordinates)
      if coordinates[0].is_a? Rectangle then
        copy_values coordinates[0]
      else
        if coordinates.size < 4 then
          raise ArgumentError, "4 numeric arguments needed"
        end
        @x = coordinates[0]
        @y = coordinates[1]
        @w = coordinates[2]
        @h = coordinates[3]
      end

      @right = @x + @w
      @bottom = @y + @h
    end

    # Accepts two points (2-element Arrays), creates Rectangle 
    # which has them as corners

    def Rectangle.new_from_points(p1, p2)
      x1, y1 = p1
      x2, y2 = p2

      x = x1 < x2 ? x1 : x2
      y = y1 < y2 ? y1 : y2

      w = (x1 - x2).abs
      h = (y1 - y2).abs

      return Rectangle.new(x,y,w,h)
    end

    def ==(r2)
      unless r2.is_a?(Rectangle) || r2.is_a?(RelativeRectangle)
        return false
      end

      return(@x == r2.left && @y == r2.top &&
        @w == r2.w && @h == r2.h)
    end

    # Returns new empty Rectangle

    def Rectangle.new_empty
      Rectangle.new(0,0,0,0)
    end

    # Takes values from another rect

    def copy_values(rect)
      @x = rect.left
      @y = rect.top
      @w = rect.w
      @h = rect.h

      @right = @x + @w
      @bottom = @y + @h

      return self
    end

    def collides?(rect)
      # if @x <= rect.right and
      #     rect.left <= @right and
      #     @y <= rect.bottom and
      #     rect.top <= @bottom then
      #   return true
      #  end
      #  return false

      # Small optimization
      return false if @x >= rect.right
      return false if rect.left > @right
      return false if @y > rect.bottom
      return false if rect.top > @bottom

      return true
    end

    # point is [x,y] Array

    def point_inside?(point)
      (point[0] >= @x && point[0] <= @right) && 
        (point[1] >= @y && point[1] <= @bottom)
    end

    def at(i)
      case i
      when 0
        return @x
      when 1
        return @y
      when 2
        return @w
      when 3
        return @h
      else
        raise ArgumentError, "Index invalid."
      end
    end

    def [](i)
      at i
    end

    def []=(i, v)
      case i
      when 0
        @x = v
      when 1
        @y = v
      when 2
        @w = v
      when 3
        @h = v
      else
        raise ArgumentError, "Index invalid."
      end

      @right = @x + @w
      @bottom = @y + @h
    end

    attr_reader :x
    alias_method :left, :x

    def x=(nx)
      @x = nx

      @right = @x + @w
      @bottom = @y + @h
    end
    alias_method(:left=, :x=)

    attr_reader :y
    alias_method :top, :y

    def y=(ny)
      @y = ny

      @right = @x + @w
      @bottom = @y + @h
    end
    alias_method(:top=, :y=)
      
    attr_accessor :w
    attr_accessor :h

    attr_reader :bottom
    attr_reader :right

    def bottom=(b)
      if b < @y then
        raise ArgumentError, "Bottom edge cannot be over top edge."
      end

      @h = b - @y

      @right = @x + @w
      @bottom = @y + @h
    end

    def right=(r)
      if r < @x then
        raise ArgumentError, "Right edge cannot be on the left of left edge."
      end

      @w = r - @x

      @right = @x + @w
      @bottom = @y + @h
    end

    # Methods returning [x,y] coordinates of corners

    def top_left
      [@x, @y]
    end

    def top_right
      [@right, @y]
    end

    def bottom_left
      [@x, @bottom]
    end

    def bottom_right
      [@right, @bottom]
    end

    # Returns an expanded copy of itself.
    # The expansion is done so that the rectangle's center stays on place and
    # it's edges move.
    #
    # r = Rectangle.new(2,2,2,2) # => [2, 2, 2, 2]
    # r.expand(1,1)              # => [1, 1, 4, 4]

    def expand(expand_x=0, expand_y=0)
      Rectangle.new(left - expand_x, top - expand_y,
                    w + 2 * expand_x, h + 2 * expand_y)
    end

    # Expand itself.

    def expand!(expand_x=0, expand_y=0)
      @x -= expand_x
      @w += 2 * expand_x
      @y -= expand_y
      @h += 2 * expand_y

      @right = @x + @w
      @bottom = @y + @h

      return self
    end

    # Expands every rect's side given amount of pixels.

    def expand2(left, right, top, bottom)
      return Rectangle.new(@x - left,
                           @y - top,
                           @w + left + right,
                           @h + top + bottom)
    end

    def expand2!(left, right, top, bottom)
      @x -= left
      @y -= top
      @w += left + right
      @h += top + bottom

      @right = @x + @w
      @bottom = @y + @h

      return self
    end

    def move(d_x, d_y)
      Rectangle.new @x+d_x, @y+d_y, @w, @h
    end

    # Moves Rectangle; returns self
    # r = Rectangle.new(100,100,10,10) # => [100,100,10,10]
    # r.move!(50,-10) # => [150,90,10,10]

    def move!(d_x, d_y)
      @x += d_x
      @y += d_y

      @right = @x + @w
      @bottom = @y + @h

      return self
    end

    def move_x!(d_x)
      move!(d_x, 0)
    end

    def move_y!(d_y)
      move!(0, d_y)
    end

    # Returns area of the Rectangle
    # Rectangle.new(50,1000,2,2).area # => 4
    # (The example is for me, because I know I'll forget meaning of the word
    # 'area' soon)

    def area
      w*h
    end

    # Returns another Rectangle, which is a common part of self and rect.
    # If there is no common part, returns an empty rect

    def common(rect)
      if ! collides?(rect) then
        return Rectangle.new_empty
      end

      result = Rectangle.new_empty
      
      if rect.left < @x then
        result.left = @x
      else
        result.left = rect.left
      end
      if rect.top < @y then
        result.top = @y
      else
        result.top = rect.top
      end
      if rect.right < @right then
        result.right = rect.right
      else
        result.right = self.right
      end
      if rect.bottom < @bottom
        result.bottom = rect.bottom
      else
        result.bottom = @bottom
      end

      return result
    end

    def empty?
      w == 0 or h == 0
    end

    def center
      [left+w/2, top+h/2]
    end

    def to_a
      [@x,@y,@w,@h]
    end

    def to_s
      "#{left}, #{top}, #{w}, #{h}"
    end

    def inspect
      "#<#{self.class}:#{self.object_id} [#{left}, #{top}, #{w}, #{h}]>"
    end

    # Does self contain r?

    def contains?(r)
      @x <= r.left && @right >= r.right &&
        @y <= r.top && @bottom >= r.bottom
    end
  end # class Rectangle
end # module FreeVikings
