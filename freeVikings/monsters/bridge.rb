# bridge.rb
# igneus 19.6.2005

# A bridge for the vikings.

#require 'platform'
require 'sprite.rb'
require 'staticobject.rb'

module FreeVikings

  class Bridge < Sprite

    include StaticObject

    def solid?
      true
    end

    def init_images
      @image = Image.load 'yellow_map/small_bridge.tga'
    end

    def register_in(location)
      location.add_sprite self
      location.add_static_object self
    end
  end # class Bridge
end # module FreeVikings
