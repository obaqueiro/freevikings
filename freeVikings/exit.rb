# exit.rb
# igneus 24.2.2005

# Exit je misto, kterym se da projit do dalsi lokace.

require 'sprite.rb'

module FreeVikings

  class Exit < Sprite

    def initialize(position)
      super position
      @image = Image.load 'exit.tga'
    end
  end
end
