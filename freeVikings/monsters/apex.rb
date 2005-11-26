# apex.rb
# igneus 2.8.2005

require 'model.rb'
require 'monstermixins.rb'
require 'hero.rb'

module FreeVikings

  # An apex which kills anyone who touches it.

  class Apex < Sprite

    include MonsterMixins::HeroBashing
    @@bash_delay = 0.1

    WIDTH = HEIGHT = 40

    def initialize(position, theme=NullGfxTheme.instance)
      super(Rectangle.new(position[0], position[1], WIDTH, HEIGHT), theme)
      @image = get_theme_image 'apex'
      @last_bash = nil
    end

    def update
      bash_heroes
    end
  end # class Apex

  # A row of Apexes. It behaves as one sprite, so it consumes
  # smaller amount of time to update it than a lot of Apexes would
  # and is also simpler to script.

  class ApexRow < Sprite

    include MonsterMixins::HeroBashing
    @@bash_delay = 0.1

    # From position only the top-left corner's coordinates are important,
    # the rest is ignored (width and height are computed)

    def initialize(position, length, theme=NullGfxTheme.instance)
      super(Rectangle.new(position[0], position[1], length*Apex::WIDTH, Apex::HEIGHT), theme)

      # Let's create the image:
      img = get_theme_image('apex')

      @surface = RUDL::Surface.new([@rect.w, @rect.h])
      @surface.set_colorkey [0,0,0]
      0.upto(length - 1) do |i|
        @surface.blit(img.image, [i*Apex::WIDTH, 0])
      end
    end

    def update
      bash_heroes
    end

    def image
      @surface
    end
  end
end # module FreeVikings
