# itemmanager.rb
# igneus 14.2.2005

# Spravce predmetu a nepohyblivych pasivnich objektu v lokaci.

module FreeVikings

  class ItemManager

    def initialize
      @items = Array.new
    end

    def add(item)
      @items.push item
    end

    def items_on_square(square)
      colliding_items = []
      @items.each { |it|
	# horni nebo dolni hranice objektu musi byt uvnitr ctverce:
	if ( ((square[1] < it.top and square[3] > it.top) or
	    (square[1] < (it.top + it.image.h) and square[1] > (it.top + it.image.h))) and
	# leva nebo prava hranice musi byt uvnitr ctverce:
	    ((square[0] < it.left and square[2] > it.left) or
	     (square[0] < (it.left + it.image.w)) and square[2] > (it.left + it.image.w)) )

      }
    end
  end # class ItemManager
end # module FreeVikings
