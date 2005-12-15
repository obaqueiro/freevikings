# tile.rb
# igneus 25.1.2005

=begin
= Tile
Instances of ((<Tile>)) are map tiles. To learn more read documentation
for class (({Map})).
=end

require 'images.rb'

module FreeVikings

  class Tile

=begin
--- Tile.new(image=nil, is_solid=true)
Makes a new ((<Tile>)).
Argument ((|is_solid|)) should be a boolean value and specifies if
the ((<Tile>)) is solid.
=end

    def initialize(image=nil, is_solid=true)
      if image then
        @image = image
      else
        @image = Image.new
      end
      @solid = is_solid
    end

=begin
--- Tile#solid?
Says if tile is solid (vikings can't go through it).
=end

    def solid?
      @solid
    end

=begin
--- Tile#image
=end

    def image
      return @image.image
    end
  end # class
end # module
