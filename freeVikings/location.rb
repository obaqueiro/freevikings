# location.rb
# igneus 14.2.2005

# Objekt Location je obalem, ktery skryva implementaci mapy apod.
# Obsahuje sam nebo ve svych clenskych promennych vsechen stav urcite
# lokality herniho sveta, ktera odpovida zhruba levelu ze hry Lost Vikings.

require 'spritemanager.rb'

module FreeVikings

  class Location

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
    end

    def add_item(item)
      @itemmanager.add item
    end

    def is_position_valid?(sprite, position)
      @spritemanager.is_position_valid? sprite, position
    end

    def blocks_on_square(square)
      @map.blocks_on_square square
    end

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
