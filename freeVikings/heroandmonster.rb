# heroandmonster.rb
# igneus 23.1.2009

require 'tombstone.rb'

module FreeVikings

  # Two empty mixins used to label object as a hero/monster.

  # Hero flag mixin.

  module Hero
  end # module Hero

  # Monster flag mixin.

  module Monster

    def destroy
      @energy = 0
      l = @location
      @location.delete_sprite self
      l.add_sprite Tombstone.new(Rectangle.new(@rect))
    end
  end
end
