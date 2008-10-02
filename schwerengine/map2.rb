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
    end

    # 2-dimensional Array of Boolean (true means solid tile). Frozen!

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

    # == Methods for loaders

    # give tile sizes

    def tile_sizes=(width, height)
      locked_test

      @tile_width = width
      @tile_height = height
    end

    # give RUDL::Surfaces

    def background=(b)
      locked_test
      @vackground = b
    end

    def foreground=(f)
      locked_test
      @foreground = f
    end

    # == Methods for map's client (e.g. Location in freeVikings)

    def paint_background(surface, paint_rect)
    end

    # If map has no foreground, nothing is done.

    def paint_foreground(surface, paint_rect)
    end

    # Says if given Rectangle is free of solid tiles.

    def area_free?(rect)
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
