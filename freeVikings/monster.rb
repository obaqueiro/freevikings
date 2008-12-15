# monster.rb
# igneus 22.2.2005

require 'tombstone.rb'

module FreeVikings

  # General mixin module for Monster Sprites.
  # Every monster class must include it (asking if this mixin has been
  # included is the way how e.g. Baleog's sword finds out which Sprite
  # to hurt and which not.)
  
  module Monster

    include SchwerEngine::Monster

    def destroy
      @energy = 0
      l = @location
      @location.delete_sprite self
      l.add_sprite Tombstone.new(Rectangle.new(@rect))
    end
  end
end
