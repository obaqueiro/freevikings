# monster.rb
# igneus 22.2.2005

# Mixin oznacujici tridu jako tridu nepratel.

require 'monsters/tombstone.rb'
require 'shield.rb'

module FreeVikings
  
  module Monster

    def destroy
      @energy = 0
      l = @location
      @location.delete_sprite self
      l.add_sprite Tombstone.new(Rectangle.new(@rect))
    end

    def stopped_by_shield?
      if @location.sprites_on_rect(self.rect).find {|s| s.kind_of? Shield} then
        return true
      end
      return false
    end
  end
end
