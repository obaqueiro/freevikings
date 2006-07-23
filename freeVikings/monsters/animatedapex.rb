# animatedapex.rb
# igneus 23.7.2006

require 'monstermixins.rb'

module FreeVikings

  class AnimatedApex < Sprite

    # Apex which periodically grows and disappears.
    # AnimatedApex is not a subclass of Apex! They just look similar
    # on the screen, but while Apex is a really simple thing, AnimatedApex
    # isn't so simple any more.

    include MonsterMixins::HeroBashing

    WIDTH = 40
    HEIGHT = 80

    def initialize(position, theme=NullGfxTheme.instance)
      super(Rectangle.new(position[0], position[1], WIDTH, HEIGHT), theme)
      @base_surface = get_theme_image('animated apex').surface
      @first_top = @rect.top
    end

    def update
      update_rect
      update_image
      bash_heroes
    end

    def image
      @surface
    end

    private

    def update_rect
      i = @location.ticker.now % 3
      c = i / 3

      @rect.h = HEIGHT * c
      @rect.top = @first_top + (HEIGHT - @rect.h)
    end

    def update_image
      @surface = @base_surface.zoom(1, @rect.h/HEIGHT, 0)
    end
  end # class AnimatedApex
end # module FreeVikings
