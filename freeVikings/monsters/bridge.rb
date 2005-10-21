# bridge.rb
# igneus 19.6.2005

# A bridge for the vikings.

require 'platform'
require 'sprite.rb'

module FreeVikings

  class Bridge < Sprite

    include Platform

    def init_images
      @image = Image.load 'yellow_map/small_bridge.tga'
    end
  end # class Bridge
end # module FreeVikings
