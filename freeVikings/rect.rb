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
      if collides_northwest? rect or
	  collides_southwest? rect or
	  collides_northeast? rect or
	  collides_southeast? rect then
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

    private

    def collides_northwest?(rect)
      if top > rect.top and top < rect.bottom and
	  left > rect.left and left < rect.right then
	return true
      end
      return nil
    end

    def collides_northeast?(rect)
      if left < rect.left and right > rect.left and
	   top < rect.bottom and bottom > rect.bottom then
	return true
      end
      return nil 
    end

    def collides_southwest?(rect)
      if bottom > rect.top and bottom < rect.bottom and
	   left > rect.left and left < rect.right then
	return true
      end
      return nil
    end

    def collides_southeast?(rect)
      if left < rect.left and right > rect.left and
	  top < rect.top and bottom > rect.top then
	return true
      end
      return nil
    end

  end # class Rectangle
end # module FreeVikings
