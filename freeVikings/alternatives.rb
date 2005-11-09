# alternatives.rb
# igneus 23.6.2005

# The critical classes have been rewritten in C++ and they can be loaded 
# as Ruby modules, but not everyone needs them and the Windows users often
# haven't got a chance to compile them (they haven't got SWIG and a C++
# compiler). So here it is where we decide whether to use Ruby or C++
# implementation.

if FreeVikings::OPTIONS["extensions"] then

  require "ext/Extensions"

  # add some missing methods to c++ written classes:

  class FreeVikings::Extensions::Rectangle
    def to_a
      [left, top, width, height]
    end

    def dup
      return self.class.new(self)
    end
  end
  FreeVikings::Rectangle = FreeVikings::Extensions::Rectangle

  class FreeVikings::Extensions::Map
    alias_method :old_init, :initialize
    def initialize(loader)
      # perform the original initialization routine:
      old_init()

      # load tiles:
      blcks = []
      loader.load_map(blcks)

      begin
        l = 0; t = 0
        blcks.each_index do |iline|
          l = iline

          next if blcks[iline].empty?

          new_tiles_line
          blcks[iline].each_index do |itile|
            t = itile
            add_tile blcks[iline][itile]
          end
        end
      rescue
        puts "Error loading tile [#{l}][#{t}]"
        raise
      end

      create_background(blcks)
    end

    attr_reader :background

    def paint(surface, paint_rect)
      surface.blit(@background, [0,0], (paint_rect.to_a))
    end

    private

    def create_background(blcks)
      @background = RUDL::Surface.new [rect.w, rect.h]

      blcks.each_index do |iline|
        blcks[iline].each_index do |itile|
          @background.blit(blcks[iline][itile].image, 
                           [TILE_SIZE*itile, TILE_SIZE*(iline-1)])
          # Notice a black hack here. Position of the tile on the @background
          # Surface: [TILE_SIZE*itile, TILE_SIZE*(iline-1)]
          # Why y == TILE_SIZE*(iline-1) ?
          # Original FreeVikings::Map is very tolerant and tolerates the
          # first line of tiles (or any other, actually) to be empty.
          # The C++ Map is very strict, so the first empty line must be
          # omitted. Than this hack is needed. I know, it needs some clean-up.
          # I'll have to clean XMLLocationLoadStrategy.
          # Later, later...
        end
      end
    end
  end
  FreeVikings::Map = FreeVikings::Extensions::Map

else

  require "rect.rb"
  require "map.rb"

end
