# killtoy.rb
# igneus 29.6.2005

require 'monster.rb'

module FreeVikings

  # Item which, when used, instantly kills all monsters in the surroundings
  # of viking who used it.
  # Looks like Mjolnir - hammer of Thor, vikings' god of thunder.

  class Killtoy < Item

    KILLRECT_WIDTH = 500
    KILLRECT_HEIGHT = 350

    def init_images
      @image = Image.load 'mjolnir.png'
    end

    def apply(user)
      loc = user.location
      x = user.rect.left - (KILLRECT_WIDTH / 2)
      y = user.rect.top - (KILLRECT_HEIGHT / 2)
      kill_rect = Rectangle.new(x, y, KILLRECT_WIDTH, KILLRECT_HEIGHT)
      user.location.sprites_on_rect(kill_rect).each do |sprite|
        sprite.destroy if sprite.kind_of? Monster
      end
      true
    end
  end # class Killtoy
end # module FreeVikings
