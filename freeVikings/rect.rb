# rect.rb
# igneus 22.2.2005

=begin
= NAME
Rectangle

= DESCRIPTION
(({Rectangle})) instance has information about a rectangular area
of the game world.

(({Rectangle})) has an equivalent class written in C++ (for efficiency).
(({FreeVikings::Extensions::Rectangle}))
=end

module FreeVikings

  class Rectangle < Array

    def initialize(*coordinates)
      if coordinates.size >= 4 then
        super(coordinates[0..3])
      else
        super(coordinates[0][0..3])
      end
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

    def top
      at 1
    end

    def top=(i)
      self[1] = i
    end

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

    def right
      left + w
    end

=begin
--- Rectangle#expand(expand_x=0, expand_y=0)
Returns an expanded copy of itself.
The expansion is done so that the rectangle's center stays on place and
it's edges move.

r = Rectangle.new(2,2,2,2) # => [2, 2, 2, 2]
r.expand(1,1)              # => [1, 1, 4, 4]
=end

    def expand(expand_x=0, expand_y=0)
      Rectangle.new(left - expand_x, top - expand_y,
                    w + 2 * expand_x, h + 2 * expand_y)
    end

    def to_a
      Array.new self[0..3]
    end

  end # class Rectangle
end # module FreeVikings
