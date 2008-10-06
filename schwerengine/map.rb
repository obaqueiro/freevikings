# map2.rb
# igneus 2.10.2008

module SchwerEngine

  # I found out that old class Map is never more suitable for freeVikings
  # and it wouldn't be simple to change it so that it would provide
  # new required features:
  # * multiple layers, some of them may be in front of game objects
  #   (foreground layers)
  # * custom tile size
  # So I decided to preserve the old class Map and develop a new one,
  # which should provide the same functionality with extensions
  # mentioned above.
  # Map was designed to suit my old freeVikings-native XML map format;
  # Map2 is designed mainly for Tiled maps (but of course it will have
  # loader for legacy-maps - I love them...)

  class Map2
    
    def initialize(loader)
      @blocks = [] # 2D Array; values are true (solid) or false (non-solid)
      @tile_width = nil
      @tile_height = nil
      @background = nil # painted before game objects
      @foreground = nil # painted after game objects (only if it exists)

      loader.load_setup(self)
      loader.load_blocks(self)
      loader.load_surfaces(self)
      lock

      @rect = Rectangle.new 0, 0, width, height
    end

    # 2-dimensional Array of Boolean (true means solid tile). 
    # Frozen as soon as it is loaded (in Map2#new)

    attr_reader :blocks

    attr_reader :tile_width
    attr_reader :tile_height

    # Returns tile size if tile width and height are the same; raises 
    # RuntimeError otherwise

    def tile_size
      if @tile_width == @tile_height then
        return @tile_width
      end

      raise "Tile width and height are different - use 'tile_width' and 'tile_height'!"
    end

    # width of the map in px

    def width
      @tile_width * @blocks[0].size
    end

    # height of the map in px

    def height
      @tile_height * @blocks.size
    end

    attr_reader :rect

    # == Methods for loaders

    # give tile sizes
    # These methods are blocked as soon as the map is loaded - don't call 
    # them (they are available only for map loaders)

    def tile_width=(w)
      locked_test
      @tile_width = w
    end

    def tile_height=(h)
      locked_test
      @tile_height = h
    end

    # give RUDL::Surfaces

    def background=(b)
      locked_test
      @background = b
    end

    def foreground=(f)
      locked_test
      @foreground = f
    end

    # == Methods for map's client (e.g. Location in freeVikings)

    def paint_background(surface, paint_rect)
      if @background == nil then
        return
      end

      rect = paint_rect.dup

      # This line "solves" one stupid problem I can't still get rid of.
      # It's dirty because it makes the first row of tiles invisible.
      # I can't find the bug which causes me to use this ####### dirty thing...
      rect.top += Map::TILE_SIZE

      surface.blit(@background, [0,0], (rect.to_a))      
    end

    alias_method :paint, :paint_background

    # If map has no foreground, nothing is done.

    def paint_foreground(surface, paint_rect)
      if @foreground == nil then
        return
      end

      rect = paint_rect.dup

      # This line "solves" one stupid problem I can't still get rid of.
      # It's dirty because it makes the first row of tiles invisible.
      # I can't find the bug which causes me to use this ####### dirty thing...
      rect.top += Map::TILE_SIZE

      surface.blit(@foreground, [0,0], (rect.to_a))
    end

    # Says if given Rectangle is free of solid tiles.

    def area_free?(rect)
      leftmost_i = (rect.left / @tile_width).floor
      rightmost_i = (rect.right / @tile_width).floor

      top_line = (rect.top / @tile_height).ceil
      bottom_line = (rect.bottom / @tile_height).ceil

      if leftmost_i < 0 then
        leftmost_i = 0
      end
      if rightmost_i > (@blocks.first.size - 1) then
        rightmost_i = @blocks.first.size - 1
      end
      if top_line < 0 then
        top_line = 0
      end
      if bottom_line > (@blocks.size - 1) then
        bottom_line = @blocks.size - 1
      end

      #print "["
      top_line.upto(bottom_line) do |line_i|
        leftmost_i.upto(rightmost_i) do |tile_i|
          #print "[#{tile_i}, #{line_i}]"
          if @blocks[line_i][tile_i] == true then
            return false
          end
        end
      end
      #puts "]"
      
      return true # solid tile hasn't been found yet, area is free
    end

    private

    def lock
      @locked = true

      @blocks.each {|l| l.freeze}
      @blocks.freeze
    end

    def locked?
      defined?(@locked) && @locked == true
    end

    def locked_test
      if locked? then
        raise MapLockedException
      end
    end

    public

    # Raised if method from API for loader is called when loading is finished

    class MapLockedException < RuntimeError
    end
  end
end
