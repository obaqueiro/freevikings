# map.rb
# igneus 20.1.2004

require 'rexml/document'

require 'tile.rb'
require 'group.rb'

=begin

= Map

A ((<Map>)) object is a data structure to store static game objects,
objects of the game world which don't change in any circumstances.
At this time a ((<Map>)) contains two types of objects - ((*tiles*)) and 
((*static objects*)).

== Tiles

Tiles are all singleton instances of class (({Tile})). Squares with sizes
((<Map::TILE_SIZE>)). They are piled into a grid. The grid is built once
when the level is loaded and there is no way to change it during the
game.
Some of them are solid and make walls and floors, the others
are soft and they are there just for good look.

== Static objects

Static objects can also be solid or soft, but they aren't placed regularly 
in a grid and can have any size. You can add them anytime you want and
delete them later. The static objects are stored in a public attribute
((|static_objects|)) which is of type (({Group})).

What sort of objects do we register as ((<Static objects>))?
* those which play a role of an atypical sized or placed piece of map
  and do not need any update (they can be just taken out of the map
  by some call from outside)
* those which do not do anything (they are in the map just for the better
  look and feel)
* those which have some methods but do not need to be updated regularly
  or to react on events (a nice example of this group of ((<Static objects>))
  is (({Lock})). Most of the time it does nothing. When some viking
  tries to use a (({Key})), the (({Key})) looks if it collides with any
  (({Lock})) and if so, (({Lock})) is asked if it can be unlocked with
  the (({Key}))).
=end

module FreeVikings

  class Map

=begin
--- Map::TILE_SIZE
((<Map>))'s tiles are squares with a side length ((<Map::TILE_SIZE>)).
=end

    TILE_SIZE = 40

=begin
--- Map.new(map_load_strategy)
Initializes a new ((<Map>)) with data from ((|map_load_strategy|)).
((|map_load_strategy|)) should be a (({LocationLoadStrategy})) instance.
=end

    def initialize(map_load_strategy)
      @log = Log4r::Logger['map log']

      @blocktypes = Hash.new
      @blocks = Array.new
      loading_strategy = map_load_strategy
      @background = nil

      @log.info('Loading map.')

      loading_strategy.load_map(@blocks, @blocktypes)

      @log.info('Map initialised.')

      @max_width = loading_strategy.max_width
      @max_height = loading_strategy.max_height
   
      @rect = Rectangle.new(0, 0, @max_width * TILE_SIZE, @max_height * TILE_SIZE)

      create_background
    end

=begin
--- Map#rect
Returns a (({Rectangle})) with ((<Map>))'s sizes. In fact only 'w' and 'h'
attributes of the returned object are important.
=end

    attr_reader :rect

=begin
--- Map#static_objects
Returns a (({Group})) of ((<Static objects>)).
=end

    attr_reader :static_objects

=begin
--- Map#background
A (({RUDL::Surface})) with all the map tiles painted. It's created only once 
when it's first required. (remember the ((<Tiles>)) can't be changed during
the game.)
=end

    attr_reader :background

=begin
--- Map#paint(surface, center_coordinate)
Paints onto the (({RUDL::Surface})) ((|surface|)) all the ((<Tiles>)) and
((<Static objects>)) which can be found in an area (({surface.w})) wide
and (({surface.h})) high with a center in ((|center_coordinate|)).
((|center_coordinate|)) is expected to be a two-element  (({Array})) 
of (({Fixnum}))s.
=end

    def paint(surface, center_coordinate)
      paint_rect = rect_on_center(center_coordinate, surface.w, surface.h)
      surface.blit(background, [0,0], (paint_rect.to_a))
    end

=begin
--- Map#area_free?(rect)
Returns ((|true|)) if area specified by the (({Rectangle})) ((|rect|)) 
is free of solid map blocks, ((|false|)) otherwise.
=end

    def area_free?(rect)
      begin
	colliding_blocks = blocks_on_rect(rect)
      rescue RuntimeError
	return false
      end
      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return false if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end

    private

    # Returns all the tiles from the area specified by rect

    def blocks_on_rect(rect)
      @log.debug "blocks_on_rect: Asked for blocks colliding with a rectangle defined by [#{rect[0]}, #{rect[1]}, #{rect[2]}, #{rect[3]}](px)"
      colliding_blocks = []
      # spocitat nejlevejsi a nejpravejsi index do kazdeho radku:
      leftmost_i = (rect[0] / Map::TILE_SIZE).to_f.floor
      rightmost_i = ((rect[0] + rect[2]) / Map::TILE_SIZE).to_f.floor
      # spocitat prvni a posledni radek:
      top_line = (rect[1] / Map::TILE_SIZE).to_f.ceil
      bottom_line = ((rect[1] + rect[3]) / Map::TILE_SIZE).to_f.ceil
      # z kazdeho radku vybrat patricny vyrez:
      @log.debug "blocks_on_rect: I'm going to extract blocks from a rect [#{leftmost_i}, #{top_line}, #{rightmost_i}, #{bottom_line}](tiles)"
      unless @blocks[top_line .. bottom_line].is_a? Array
	@log.error "blocks_on_rect: Invalid lines #{top_line} .. #{bottom_line}."
	raise RuntimeError, "Invalid lines #{top_line} .. #{bottom_line}."
      end
      @blocks[top_line .. bottom_line].each {|line|
	blocks = line[leftmost_i .. rightmost_i]
	colliding_blocks.concat(blocks) if blocks.is_a? Array
      }
      return colliding_blocks
    end

    # Creates a new RUDL::Surface @background and paints images of all the
    # tiles onto it.

    def create_background
      @background = RUDL::Surface.new([@rect.w, @rect.h])
	
      @blocks.each_index { |row_i|
        @blocks[row_i].each_index { |col_i|
          block_type = @blocks[row_i][col_i]
          if block_type.nil?
            @log.error("Blocktype object for block [#{row_i}][#{row_i}] wasn't found in map's internal hash.")
          end
          if block_type.is_a? Tile
            @background.blit(block_type.image, [col_i * TILE_SIZE, (row_i - 1) * TILE_SIZE])
          else
            @log.error("Found blocktype object of strange type #{block_type.type.to_s} at index [" + row_i.to_s + '][' + col_i.to_s + '] (expected Tile)')
          end
        }
      }
    end

    # Returns a Rectangle width wide and height high with a center 
    # in center_coord

    def rect_on_center(center_coordinate, width, height)
      left = center_coordinate[0] - (width / 2)
      top = center_coordinate[1] - (height / 2)
      
      # Pozadovany stred nekde u zacatku mapy:
      left = 0 if center_coordinate[0] < (width / 2)
      top = 0 if center_coordinate[1] < (height / 2)
      # Pozadovany stred nekde u konce mapy:
      left = (background().w - width) if center_coordinate[0] > (background().w - (width / 2))
      top = (background().h - height) if center_coordinate[1] > (background().h - (height / 2))
      
      Rectangle.new(left, top, left + width, top + height)
    end

  end # class Map

end # modulu FreeVikings
