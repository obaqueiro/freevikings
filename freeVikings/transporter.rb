# transporter.rb
# igneus 17.9.2008

module FreeVikings

  # Mixin for objects which transport vikings
  # (such as various flying platforms etc.)
  #
  # See monsters/flyingplatform.rb and monsters/lift.rb for example

  module Transporter

    # Transportable calls this, passing itself as argument, to request
    # end of transport

    def end_transport_of(sprite)
      @transported.delete sprite
      sprite.end_transport self
    end

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
      find_transported_sprites
      move_transported_sprites(delta_x, delta_y)      
    end

    # If you need to do something between finding transported sprites
    # and moving them (e.g. move the Transporter itself), you can
    # use the two parts of Transporter#update_transported_sprites separately:

    def find_transported_sprites
      collision_rect = @rect.expand(1,2)

#       @transported.delete_if {|s|
#         unless s.rect.collides? collision_rect
#           s.end_transport self
#           # puts 'Good bye'
#           true
#         end
#       }

      @location.sprites_on_rect(collision_rect) {|s|
        if s.kind_of? Transportable and
            (not @transported.include? s) then
          @transported.push s
          # puts 'Halle'
          s.start_transport self
        end
      }
    end

    def move_transported_sprites(delta_x, delta_y)
      @transported.each {|s|
        s.transport_move(delta_x, delta_y, self)
      }
    end
  end
end
