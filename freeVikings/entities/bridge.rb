# bridge.rb
# igneus 19.6.2005

module FreeVikings

  # A bridge for the vikings.
  # !!! Bridge.new needs two arguments: position and theme!

  class Bridge < Entity

    include StaticObject

    WIDTH = 120
    HEIGHT = 40

    def solid?
      true
    end

    def init_images
      @image = get_theme_image 'bridge'
    end
  end # class Bridge
end # module FreeVikings
