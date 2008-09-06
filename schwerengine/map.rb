# map.rb
# igneus 20.1.2004

require 'rexml/document'

module SchwerEngine

  # A Map object is a data structure to store static game objects,
  # objects of the game world which don't change in any circumstances.
  # At this time a Map contains one type of objects - tiles.
  #
  # Tiles are all singleton instances of class Tile. Squares with sizes
  # Map::TILE_SIZE. They are piled into a grid. The grid is built once
  # when the level is loaded and there is no way to change it during the
  # game.
  # Some of them are solid and make walls and floors, the others
  # are soft and they are there just for good look.
  #
  # Some more static objects are stored in Location. (See Static objects.)

  class Map

    # Map's tiles are squares with a side length Map::TILE_SIZE.
    TILE_SIZE = 40

    # Initializes a new Map with data from map_load_strategy.
    # map_load_strategy should be a MapLoadStrategy instance.

    def initialize(map_load_strategy)
      @log = Log4r::Logger['map log']

      @blocks = Array.new
      loading_strategy = map_load_strategy
      @background = nil

      @log.info('Loading map.')

      loading_strategy.load_map(@blocks)

      @max_width = @blocks[1].size
      @max_height = @blocks.size

      @log.info("Map initialised. Size '#{@max_width}x#{@max_height}'")

      if (@max_width == 0) or (@max_height == 0) then
        raise "Invalid map size: #{@max_width}x#{@max_height}"
      end

      @rect = Rectangle.new(0, 0, @max_width*TILE_SIZE, @max_height*TILE_SIZE)

      create_background
    end

    # Returns a Rectangle with Map's sizes. In fact only 'w' and 'h'
    # attributes of the returned object are important.

    attr_reader :rect

    # Returns a Group of Static objects.

    attr_reader :static_objects

    # A RUDL::Surface with all the map tiles painted. It's created only once 
    # when it's first required. (remember the Tiles can't be changed during
    # the game.)

    attr_reader :background

    def paint(surface, paint_rect)
      rect = paint_rect.dup

      # This line "solves" one stupid problem I can't still get rid of.
      # It's dirty because it makes the first row of tiles invisible.
      # I can't find the bug which causes me to use this ####### dirty thing...
      rect.top += Map::TILE_SIZE

      surface.blit(@background, [0,0], (rect.to_a))
    end

    # Returns true if area specified by the Rectangle rect 
    # is free of solid map blocks, false otherwise.

    def area_free?(rect)
      leftmost_i = (rect.left / Map::TILE_SIZE).floor
      rightmost_i = (rect.right / Map::TILE_SIZE).floor

      top_line = (rect.top / Map::TILE_SIZE).ceil
      bottom_line = (rect.bottom / Map::TILE_SIZE).ceil

      #print "["
      top_line.upto(bottom_line) do |line_i|
        leftmost_i.upto(rightmost_i) do |tile_i|
          #print "[#{tile_i}, #{line_i}]"
          begin
            if @blocks[line_i][tile_i].solid? then
              return false
            end
          rescue NoMethodError
            # Occurs when solid? called on nil (no tile at [line_i][tile_i])
            @log.warn "No tile found at [#{line_i}][#{tile_i}]"
            return false
          end
        end
      end
      #puts "]"
      
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
          unless block_type.is_a? Tile
            @log.error("Found blocktype object of strange type #{block_type.class.to_s} at index [" + row_i.to_s + '][' + col_i.to_s + '] (expected Tile)')
          end
         
          begin   
            @background.blit(block_type.image, [col_i * TILE_SIZE, row_i * TILE_SIZE])
          rescue => ex
            @log.error "#{ex.class} Error occured when blitting tile #{block_type.inspect}."
            raise
          end
        }
      }
    end
  end # class Map

end # modulu SchwerEngine
