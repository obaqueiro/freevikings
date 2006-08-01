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

    ANIMATION_PERIOD = 5

    def update_rect
      ap = animation_period
      i = @location.ticker.now % ap
      c = i / ap

      if c <= 0.5 then
        @rect.h = HEIGHT * c * 2
      else
        @rect.h = HEIGHT - (HEIGHT * (c - 0.5) * 2)
      end
      @rect.top = @first_top + (HEIGHT - @rect.h)
    end

    def update_image
      @surface = @base_surface.zoom(1, @rect.h/HEIGHT, 0)
    end

    def animation_period
      ANIMATION_PERIOD
    end
  end # class AnimatedApex
end # module FreeVikings
