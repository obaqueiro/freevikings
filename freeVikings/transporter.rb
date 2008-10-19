# transporter.rb
# igneus 17.9.2008

module FreeVikings

  # Mixin for objects which transport vikings
  # (such as various flying platforms etc.)
  #
  # See monsters/flyingplatform.rb and monsters/lift.rb for example

  module Transporter

    private

    # call this from YourTransporterClass#initialize, please

    def init_transporter
      @transported = []
    end

    # Finds sprites which should be transported
    # and transports them.
    # delta_x and delta_y are pixels to move the sprite...
    # update_transported_sprites(-12,60) moves sprites 12px left and 60px down

    def update_transported_sprites(delta_x, delta_y)
      collision_rect = @rect.expand(1,1)

      colliding_sprites = @location.sprites_on_rect(collision_rect)

      @transported.delete_if {|s|
        unless s.rect.collides? collision_rect
          s.end_transport self
          # puts 'Good bye'
          true
        end
      }

      colliding_sprites.each {|s|
        if s.kind_of? Transportable and
            (not @transported.include? s) then
          @transported.push s
          # puts 'Halle'
          s.start_transport self
        end
      }

      @transported.each {|s|
        s.transport_move(delta_x, delta_y, self)
      }
    end
  end
end
