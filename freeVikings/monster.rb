# monster.rb
# igneus 22.2.2005

# Mixin oznacujici tridu jako tridu nepratel.

require 'monsters/tombstone.rb'

module FreeVikings
  
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
