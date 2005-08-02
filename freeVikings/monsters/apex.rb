# apex.rb
# igneus 2.8.2005

require 'imagebank'
require 'hero.rb'

module FreeVikings
  class Apex < Sprite

    def initialize(position)
      super(Rectangle.new(position[0], position[1], 40, 40))
      @image = FreeVikings::Image.load 'apex.tga'
    end

    def update
      colliding_sprites = @location.sprites_on_rect(rect)
      colliding_sprites.each {|s| s.hurt if s.kind_of? Hero}
    end
  end # class Apex
end # module FreeVikings
