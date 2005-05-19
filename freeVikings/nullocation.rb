# nullocation.rb
# igneus 7.3.2005

# Nulovy objekt pro Location

require 'location.rb'

module FreeVikings

  class NullLocation < Location

    def initialize(loader=nil)
    end

    def update
    end

    def paint(surface, center)
    end

    def background
      Image.new
    end

    def add_sprite(sprite)
    end

    attr_accessor :exitter

    def delete_sprite(sprite)
    end

    def sprites_on_rect(rect)
      []
    end

    def is_position_valid?(sprite, position)
      true
    end

  end # class NullLocation
end # module FreeVikings
