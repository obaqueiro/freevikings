# rect.rb
# igneus 22.2.2005

# Trida obalujici operace nad obdelnikovymi vyrezy.

module FreeVikings

  class Rectangle < Array

    def initialize(*coordinates)
      super(coordinates[0..3])
    end

    def contains?(rect)
      if left <= rect.left and top <= rect.top and
	  right >= rect.right and bottom >= rect.bottom then
	return true
      end
      return nil
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

    def to_a
      Array.new self[0..3]
    end

  end # class Rectangle
end # module FreeVikings
