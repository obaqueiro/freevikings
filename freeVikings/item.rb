# item.rb
# igneus 14.2.2005

# Pasivni objekt v lokaci

module FreeVikings

  class Item

    def initialize(position)
      @position = position
    end

    def top
      @position[1]
    end

    def left
      @position[0]
    end

    def image
      RUDL::Surface.new([40,40])
    end
  end
end
