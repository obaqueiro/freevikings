# transporterbridge.rb
# igneus 6.10.2005

# TransporterBridge is a Bridge which can transport the Transportable
# game objects like a lift.

require 'monsters/bridge.rb'
require 'gfxtheme.rb'
require 'transportable.rb'

module FreeVikings

  class TransporterBridge < FallingBridge

    def initialize(left, ys, theme=NullGfxTheme.instance)
      super(left, *ys)
      @theme = theme

      @image = get_theme_image 'bridge'
      @rect.w = @image.image.w

      @y.sort!          # Array of destinations created by Bridge.new

      @transported = [] # Array of the transported sprites

      @dest = 0         # subscript of the next destination y
    end

    attr_writer :dest

    def move_up
      @dest -= 1 if @dest > 0
    end

    def move_down
      @dest += 1 if @dest < (@y.size - 1)
    end

    def update
      update_transported_sprites
      old_rect = @rect.dup

      update_position

      delta_y = @rect.top - old_rect.top
      @transported.each {|s|
        s.transport_move(0, delta_y, self)
      }
    end

    def location=(new_location)
      old_loc = @location
      super(new_location)

      # The TransportBridge is also an ActiveObject.
      # It's because it can be driven by the cursor keys.
      if new_location.kind_of? NullLocation
        old_loc.activeobjectmanager.delete self
      else
        @location.activeobjectmanager.add self
      end
    end

    def activate
      move_up
    end

    def deactivate
      move_down
    end

    private

    def in_destination?
      @y[@dest] == @rect.top
    end

    def update_position
      if @rect.top != @y[@dest] then
        total_delta_y = (@y[@dest] - @rect.top)

        if total_delta_y.abs <= 10 then
          @rect.top = @y[@dest]
        else
          @rect.top += total_delta_y.signum * VELOCITY * @location.ticker.delta
        end
      end
    end

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
  end # class TransporterBridge
end # module FreeVikings

# A little extension of the built-in class
class Numeric
  def signum
    return 0 if self.to_i == 0
    return self / self.abs
  end
end
