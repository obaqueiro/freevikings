# flyingplatform.rb
# igneus 10.10.2005

=begin
= NAME
FlyingPlatform
=end

require 'monsters/bridge.rb'
require 'transporter.rb'

module FreeVikings

  class FlyingPlatform < Sprite

    include Transporter
    include StaticObject

    WIDTH = 120
    HEIGHT = 40

    VELOCITY = 50

=begin
= Class methods

--- FlyingPlatform.new(destinations, theme)
((|destinations|)) must be an (({Array})) of two-element (({Array}))s,
e.g.: [[0,23], [20,10], [56,234]].
It's used as a list of coordinates the (({FlyingPlatform})) flies through.
((|theme|)) must be a (({GfxTheme})) instance.
=end

    def initialize(destinations, _theme)
      super(destinations[0], _theme)
      init_transporter

      @destinations = destinations
      @image = get_theme_image 'bridge'
      @rect.w = @image.image.w
      @rect.h = @image.image.h
      @dest = 0
    end

    def update
      update_transported_sprites

      old_rect = @rect.dup

      update_position

      delta_y = @rect.top - old_rect.top
      delta_x = @rect.left - old_rect.left
      @transported.each {|s|
        s.transport_move(delta_x, delta_y, self)
      }
    end


    def in_destination?
      (@destinations[@dest][0] == @rect.left and
         @destinations[@dest][1] == @rect.top)
    end

    def solid?
      true
    end

    def init_images
      @image = get_theme_image 'bridge'
    end

    def register_in(loc)
      loc.add_sprite self
      loc.add_static_object self
    end

    private

    def update_position
      if @rect.top == @destinations[@dest][1] and
          @rect.left == @destinations[@dest][0] then

        if @dest < @destinations.size - 1 then
          @dest += 1
        else
          @dest = 0
        end

        # puts @destinations[@dest]

      else
        
        total_delta_y = (@destinations[@dest][1] - @rect.top)
        total_delta_x = (@destinations[@dest][0] - @rect.left)

        if total_delta_y.abs <= 10 then
          @rect.top = @destinations[@dest][1]
        else
          @rect.top += total_delta_y.signum * VELOCITY * @location.ticker.delta
        end

        if total_delta_x.abs <= 10 then
          @rect.left = @destinations[@dest][0]
        else
          @rect.left += total_delta_x.signum * VELOCITY * @location.ticker.delta
        end
      end
    end

  end # class FlyingPlatform
end # module FreeVikings
