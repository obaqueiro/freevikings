# nullocation.rb
# igneus 7.3.2005

# Null object for Location.
# It doesn't provide full Location interface, but only what
# sprites use.

require 'singleton'

module FreeVikings

  class NullLocation # < Location

    include Singleton

    def initialize(loader=nil)
      @ticker = Ticker.new
    end

    def update
    end

    def paint(surface, center)
    end

    def background
      Image.load
    end

    def add_sprite(sprite)
    end

    attr_accessor :exitter

    def delete_sprite(sprite)
    end

    def sprites_on_rect(rect)
      []
    end

    def area_free?(rect)
      true
    end

    def rect_inside?(rect)
      raise NullLocationException, "Method 'rect_inside?' should never be called over NullLocation object. It has sense in full-featured Location instances only."
    end

    # This exception is raised when a method is called which only has sense 
    # for real
    # Location instances.

    class NullLocationException < RuntimeError
    end

  end # class NullLocation
end # module
