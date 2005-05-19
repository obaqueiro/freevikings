# rect.rb
# igneus 22.2.2005

# Trida obalujici operace nad obdelnikovymi vyrezy.

module FreeVikings

  class Rectangle

    def initialize(*coordinates)
      @coordinates = coordinates[0..3]
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
      @coordinates[0]
    end

    def top
      @coordinates[1]
    end

    def w
      @coordinates[2]
    end

    def h
      @coordinates[3]
    end

    def bottom
      top + h
    end

    def right
      left + w
    end

    def to_a
      @coordinates.dup
    end

  end # class Rectangle
end # module FreeVikings
