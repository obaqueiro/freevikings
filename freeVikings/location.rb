# location.rb
# igneus 14.2.2005

# Objekt Location je obalem, ktery skryva implementaci jednotlivych operaci
# pred svymi spolupracovniky. Je pomerne velky, ale vetsinu funkci
# deleguje.
# Obsahuje sam nebo ve svych clenskych promennych vsechen stav urcite
# lokality herniho sveta, ktera odpovida zhruba levelu ze hry Lost Vikings.

require 'map.rb'
require 'spritemanager.rb'
require 'activeobjectmanager.rb'
require 'itemmanager.rb'

module FreeVikings

  class Location

    def initialize(loader)
      @exitter = nil # objekt Exit - cesta do dalsi lokace
      @start = [0,0] # misto, kde zacinaji vikingove svou misi

      @map = Map.new(loader)
      @spritemanager = SpriteManager.new
      @activeobjectmanager = ActiveObjectManager.new
      @itemmanager = ItemManager.new
      loader.load_scripts(self)
      loader.load_exit(self)
      loader.load_start(self)
    end

    def update
      @spritemanager.update
    end

    def pause
      @spritemanager.pause
    end

    def unpause
      @spritemanager.unpause
    end

    def paint(surface, center)
      @map.paint(surface, center)
      displayed_rect = centered_view_rect(background.w, background.h, surface.w, surface.h, center)
      @activeobjectmanager.paint(surface, displayed_rect)
      @itemmanager.paint(surface, displayed_rect)
      @spritemanager.paint(surface, displayed_rect)
    end

    def background
      @map.background
    end

    def exitter=(exitter)
      @exitter = exitter
      add_sprite exitter
    end

    attr_reader :exitter

    attr_accessor :start

    def add_sprite(sprite)
      sprite.location = self
      @spritemanager.add sprite
    end

    def delete_sprite(sprite)
      @spritemanager.delete sprite
      sprite.location = NullLocation.new # nullocation.rb is required at 
                                         # the end of file
    end

    def sprites_on_rect(rect)
      @spritemanager.sprites_on_rect rect
    end

    def add_active_object(object)
      @activeobjectmanager.add object
    end

    def delete_active_object(object)
      @activeobjectmanager.delete object
    end

    def active_objects_on_rect(rect)
      @activeobjectmanager.members_on_rect(rect)
    end

    def add_item(item)
      @itemmanager.add item
    end

    def delete_item(item)
      @itemmanager.delete item
    end

    def items_on_rect(rect)
      @itemmanager.members_on_rect(rect)
    end

    def rect_inside?(rect)
      @map.rect.collides? rect
    end

    def is_position_valid?(sprite, position)
      begin
	colliding_blocks = blocks_on_rect([position[0], position[1], sprite.rect.w, sprite.rect.h])
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

    def blocks_on_rect(rect)
      @map.blocks_on_square(rect)
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
      Rectangle.new(top_left_left, top_left_top, bottom_right_left, bottom_right_top)
    end

  end # class Location
end # module FreeVikings

require 'nullocation.rb'
