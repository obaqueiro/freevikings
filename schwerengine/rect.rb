# rect.rb
# igneus 22.2.2005

=begin
= NAME
Rectangle

= DESCRIPTION
(({Rectangle})) instance has information about a rectangular area
of the game world.
=end

module SchwerEngine

  class Rectangle < Array

    def initialize(*coordinates)
      if coordinates.size >= 4 then
        super(coordinates[0..3])
      else
        super(coordinates[0][0..3])
      end
    end

    # Returns new empty Rectangle

    def Rectangle.new_empty
      Rectangle.new(0,0,0,0)
    end

    def collides?(rect)
      if self.left <= rect.right and
	  rect.left <= self.right and
	  self.top <= rect.bottom and
	  rect.top <= self.bottom then
	return true
      end
      return false
    end

    def left
      at 0
    end

    def left=(i)
      self[0] = i
    end

    alias_method :x, :left
    alias_method :x=, :left=

    def top
      at 1
    end

    def top=(i)
      self[1] = i
    end

    alias_method :y, :top
    alias_method :y=, :top=

    def w
      at 2
    end

    def w=(i)
      self[2] = i
    end

    def h
      at 3
    end

    def h=(i)
      self[3] = i
    end

    def bottom
      top + h
    end

    def bottom=(b)
      if b < top then
        raise ArgumentError, "Bottom edge cannot be over top edge."
      end

      self.h = b - top
    end

    def right
      left + w
    end

    def right=(r)
      if r < left then
        raise ArgumentError, "Right edge cannot be on the left of left edge."
      end

      self.w = r - left
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
      
      if rect.left < self.left then
        result.left = self.left
      else
        result.left = rect.left
      end
      if rect.top < self.top then
        result.top = self.top
      else
        result.top = rect.top
      end
      if rect.right < self.right then
        result.right = rect.right
      else
        result.right = self.right
      end
      if rect.bottom < self.bottom
        result.bottom = rect.bottom
      else
        result.bottom = self.bottom
      end

      return result
    end

    def empty?
      w == 0 or h == 0
    end

    def to_a
      Array.new self[0..3]
    end

    def to_s
      "[#{left}, #{top}, #{w}, #{h}]"
    end
  end # class Rectangle
end # module FreeVikings
