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
    # aktualni lokace, jehoz obsah se ma na surface vykreslit.
    # Vykresli vsechny viditelne sprajty.
    # Definice obdelnika:
    # 0 - topleft x; 1 - topleft y; 2 - bottomright x; 3 - bottomright y;

    def paint(surface, rect_of_location)
      update
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

    # Projde vsechny sprajty a zavola na nich update (v teto metode se hlavne
    # aktualisuje posice, ale inteligentni obludy mohou napr. i premyslet).

    def update
      @sprites.each { |sprite|
	# at je pekne aktualni:
	sprite.update
	# jestli se sprajt dostal mimo mapu, musi byt odstranen.
	if sprite.top < 0 or sprite.top > @map.background.h or
	    sprite.left < 0 or sprite.left > @map.background.w then
	  sprite.destroy
	end
      }
    end

    # Vrati true nebo nil, podle toho, jestli je mozne vstoupit do obdelniku
    # (daneho polem ctyr cisel) bez kolize ve vertikalnim smeru

    def is_vertical_position_valid?(sprite, new_pos)
      # kolize na svrchnim okraji:
      colliding_blocks = @map.blocks_on_line([new_pos[0], new_pos[1], new_pos[0] + sprite.image.w, new_pos[1]])
      # kolize na spodnim okraji:
      colliding_blocks.concat @map.blocks_on_line([new_pos[0], new_pos[1] + sprite.image.h, new_pos[0] + sprite.image.w, new_pos[1] + sprite.image.h])

      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return nil if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end

    # Vrati true nebo nil, podle toho, jestli je mozne vstoupit do obdelniku
    # (daneho polem ctyr cisel) bez kolize v horisontalnim smeru

    def is_horizontal_position_valid?(sprite, new_pos)
      # kolize na levem okraji:
      colliding_blocks = @map.blocks_on_line([new_pos[0], new_pos[1], new_pos[0], new_pos[1] + sprite.image.h])
      # kolize na pravem okraji:
      colliding_blocks.concat @map.blocks_on_line([new_pos[0] + sprite.image.w, new_pos[1], new_pos[0] + sprite.image.w, new_pos[1] + sprite.image.h])

      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return nil if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end

  end
end #module FreeVikings
