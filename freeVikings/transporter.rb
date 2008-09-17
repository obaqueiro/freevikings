# transporter.rb
# igneus 17.9.2008

module FreeVikings

  # Mixin for objects which transport vikings
  # (such as various flying platforms etc.)
  #
  # See monsters/flyingplatform.rb for example

  module Transporter

    private

    # Finds sprites which should be transported
    # and transports them.

    def update_transported_sprites
      colliding_sprites = @location.sprites_on_rect(@rect)

      @transported.delete_if {|s|
        unless s.rect.collides? @rect
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
    end

    # call this from YourTransporterClass#initialize, please

    def init_transporter
      @transported = []
    end
  end
end
