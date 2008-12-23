# mockclasses.rb
# igneus 13.2.2005

# Collection of mock classes which are useful for unit testing.

module FreeVikings

  module Mock

    # A location loading Strategy (for Location tests).
    # It doesn't parse any XML files => the tests are quicker.

    class TestingMapLoadStrategy < MapLoadStrategy

      def initialize
        super(nil)

        @tile_width = @tile_height = 40

	x = true
	o = false

	@blocks = [
	  [x, x, x, x, x, x, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, o, o, o, o, o, x, x],
	  [x, x, x, x, x, x, x, x]
	]
      end

      # methods imitating behaviour of LocationLoader (it is common for my
      # mock objects that they often mock more then one "real object")

      def map_loader
        self
      end

      def load_exit(location)
      end

      def load_start(location)
      end

      def load_script(location)
      end
    end # class TestingMapLoadStrategy

    # A corrupted class MockLocation.
    # A mock location has no internal mechanism, it just stores
    # the data we want her to return from method calls.
    class MockLocation
      def initialize
        @position_validator_proc = Proc.new {|sprite, position| true}
        @sprites_on_rect = []
        @sprites = []
        @ticker = Ticker.new
      end

      attr_accessor :sprites
      attr_writer :sprites_on_rect
      attr_accessor :position_validator_proc
      attr_accessor :ticker

      def add_sprite(sprite)
        @sprites << sprite
        sprite.location = self
      end

      def <<(s)
        @sprites << s
      end

      def delete_sprite(sprite)
        @sprites.delete sprite
      end
      
      def area_free?(area)
        return @position_validator_proc.call(nil, area)
      end

      def sprites_on_rect(rect)
        @sprites_on_rect.dup
      end

      def add_item(item)
      end

      def active_objects_on_rect(rect)
        []
      end

      def items_on_rect(rect)
        []
      end

      # Really mocked!

      def find_surface(rect)
        Rectangle.new(40, (8-1)*40, 40*8, 40)
      end
    end

    class CorruptedTicker
      attr_accessor :ticks
      attr_accessor :old
      attr_accessor :now
      attr_accessor :delta
    end # class CorruptedTicker

  end # module Mock
end # module FreeVikings
