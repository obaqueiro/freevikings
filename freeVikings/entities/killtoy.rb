# killtoy.rb
# igneus 29.6.2005

=begin
= Killtoy
((<Killtoy>)) is a small Item, something like an orion-star used for
the insidious fight. It is an Item magical abilities. When it is used,
all the Monsters in the area die.
=end

require 'monster.rb'

module FreeVikings

  class Killtoy < Item

    KILLRECT_WIDTH = 500
    KILLRECT_HEIGHT = 350

    def init_images
      @image = Image.load 'killtoy.tga'
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
