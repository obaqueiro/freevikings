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
--- Tile.new(filename='', is_solid=true)
Makes a new ((<Tile>)) with an image from file with name ((|filename|)).
Argument ((|is_solid|)) should be a boolean value and specifies if
the ((<Tile>)) is solid.
=end

    def initialize(filename='', is_solid=true)
      if filename and filename.size != 0 then
        @image = Image.load(filename)
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
