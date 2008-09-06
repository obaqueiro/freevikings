# tile.rb
# igneus 25.1.2005


module SchwerEngine

  # Instances of Tile are map tiles. To learn more read documentation
  # for class Map.

  class Tile

    # Makes a new Tile.
    # Argument is_solid should be a boolean value and specifies if
    # the Tile is solid.

    def initialize(image=nil, is_solid=true)
      if image then
        unless image.kind_of? Image
          raise ArgumentError, "Image expected, given #{image.class}"
        end

        @image = image
        @empty = false
      else
        @image = Image.new
        @empty = true
      end
      @solid = is_solid
    end

    # Says if tile is solid (vikings can't go through it).

    def solid?
      @solid
    end

    # Empty tile is a Tile which has no image (was initialized by nil).

    def empty?
      @empty
    end

    # Returns a solid copy of itself.

    def to_solid
      # This ensures all the internals are copied, only @solid is changed
      t = self.dup
      t.instance_eval { @solid = true }
      return t
    end

    def image
      return @image.image
    end
  end # class
end # module
