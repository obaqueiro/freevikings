# location.rb
# igneus 14.2.2005

# Objekt Location je obalem, ktery skryva implementaci jednotlivych operaci
# pred svymi spolupracovniky. Je pomerne velky, ale vetsinu funkci
# deleguje.
# Obsahuje sam nebo ve svych clenskych promennych vsechen stav urcite
# lokality herniho sveta, ktera odpovida zhruba levelu ze hry Lost Vikings.

require 'spritemanager.rb'
require 'movevalidator.rb'

module FreeVikings

  class Location

    include MoveValidator

    def initialize(loader)
      @spritemanager = SpriteManager.new(self)
      @itemmanager = nil
      @map = Map.new(loader)
    end

    def update
      @spritemanager.update
    end

    def paint(surface, center)
      @map.paint(surface, center)
      @spritemanager.paint(surface, centered_view_rect(background.w, background.h, surface.w, surface.h, center))

    end

    def background
      @map.background
    end

    def add_sprite(sprite)
      @spritemanager.add sprite
      sprite.each_displayable { |d|
	d.move_validator = self if d.respond_to? :move_validator=
      }
    end

    def delete_sprite(sprite)
      @spritemanager.delete sprite
    end

    def add_item(item)
      @itemmanager.add item
    end

    def is_position_valid?(sprite, position)
      @spritemanager.is_position_valid? sprite, position
    end

    def blocks_on_rect(rect)
      @map.blocks_on_square rect
    end

    def sprites_on_rect(rect)
      @spritemanager.sprites_on_rect rect
    end

    def is_position_valid?(sprite, position)
      begin
	colliding_blocks = blocks_on_rect([position[0], position[1], sprite.image.w, sprite.image.h])
      rescue RuntimeError
	return nil
      end
      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return nil if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end # is_position_valid?

    private

    # vraci pole ctyr prvku definujicich obdelnik centrovany predanymi 
    # souradnicemi bodu, pokud tyto souradnice nejsou moc blizko okrajum
    # plochy
    # width, height - sirka a vyska plochy, po ktere se pohybujeme
    # view_width, view_height - sirka a vyska zobrazeni
    # center_coord - souradnice pozadovaneho stredu

    def centered_view_rect(width, height, view_width, view_height, center_coord)
      # vypocet leve souradnice leveho horniho rohu:
      if center_coord[0] < (view_width / 2)
	# stred moc u zacatku
	top_left_left = 0
      elsif center_coord[0] > (width - (view_width / 2))
	# stred moc u konce
	top_left_left = width - view_width
      else
	top_left_left = center_coord[0] - (view_width / 2)
      end
      # vypocet svrchni souradnice leveho horniho rohu:
      if center_coord[1] < (view_height / 2)
	# stred moc u zacatku
	top_left_top = 0
      elsif center_coord[1] > (height - (view_height / 2))
	# stred moc u konce
	top_left_top = height - view_height
      else
	top_left_top = center_coord[1] - (view_height / 2)
      end
      bottom_right_left = top_left_left + view_width
      bottom_right_top = top_left_top + view_height
      [top_left_left, top_left_top, bottom_right_left, bottom_right_top]
    end

  end # class Location
end # module FreeVikings
