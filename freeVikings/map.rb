# map.rb
# igneus 20.1.2004

require 'rexml/document'

require 'tile.rb'
require 'group.rb'

=begin

= Map

A ((<Map>)) object is a data structure to store static game objects,
objects of the game world which don't change in any circumstances.
At this time a ((<Map>)) contains one type of objects - ((*tiles*)).

Tiles are all singleton instances of class (({Tile})). Squares with sizes
((<Map::TILE_SIZE>)). They are piled into a grid. The grid is built once
when the level is loaded and there is no way to change it during the
game.
Some of them are solid and make walls and floors, the others
are soft and they are there just for good look.

Some more static objects are stored in (({Location})). (See Static objects.)
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

      @blocks = Array.new
      loading_strategy = map_load_strategy
      @background = nil

      @log.info('Loading map.')

      loading_strategy.load_map(@blocks)

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

    def paint(surface, paint_rect)
      surface.blit(background, [0,0], (paint_rect.to_a))
    end

=begin
--- Map#area_free?(rect)
Returns ((|true|)) if area specified by the (({Rectangle})) ((|rect|)) 
is free of solid map blocks, ((|false|)) otherwise.
=end

    def area_free?(rect)
      leftmost_i = (rect.left / Map::TILE_SIZE).floor
      rightmost_i = (rect.right / Map::TILE_SIZE).floor

      top_line = (rect.top / Map::TILE_SIZE).ceil
      bottom_line = (rect.bottom / Map::TILE_SIZE).ceil

      top_line.upto(bottom_line) do |line_i|
        leftmost_i.upto(rightmost_i) do |tile_i|
          if @blocks[line_i][tile_i].solid? then
            return false
          end
        end
      end
      
      return true # solid tile hasn't been found yet, area is free
    end

    private

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
  end # class Map

end # modulu FreeVikings
