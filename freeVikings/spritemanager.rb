# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'movevalidator'

module FreeVikings

  class SpriteManager

    include MoveValidator

    def initialize(map)
      @sprites = Array.new
      @map = map
    end

    def add(sprite)
      @sprites.push(sprite)
      sprite.move_validator = self if sprite.respond_to? :move_validator=
    end

    # Metoda dostane surface a pole ctyr cisel definujicich obdelnik z plochy
    # aktualni lokace, jehoz obsah se ma na surface vykreslit. Po navratu 
    # z metody budou na surface vykresleny vsechny sprajty.

    def paint(surface, rect_of_location)
      @sprites.each { |sprite|
	if sprite.top > rect_of_location[1] and
	    sprite.top < rect_of_location[3] and
	    sprite.left > rect_of_location[0] and
	    sprite.left < rect_of_location[2] then
	  relative_left = sprite.left - rect_of_location[0]
	  relative_top = sprite.top - rect_of_location[1]
	  surface.blit(sprite.image, [relative_left, relative_top])
	end
      }
    end

    # Vrati true nebo nil, podle toho, jestli je mozne vstoupit do obdelniku
    # (daneho polem ctyr cisel) bez kolize

    def is_position_valid?(sprite, new_pos)
      colliding_blocks = @map.blocks_on_line([new_pos[0], new_pos[1], new_pos[0], new_pos[1] + sprite.image.h])

      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return nil if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end
  end
end #module FreeVikings
