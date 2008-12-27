# lift.rb
# igneus 6.10.2005

require 'transportable.rb'
require 'transporter.rb'

module FreeVikings

  # Lift is a platform which can move up and down.
  # Any Sprite which includes Transportable can be given 
  # a lift by this lift.

  class Lift < Sprite

    include Transporter
    include StaticObject

    # abs of vertical velocity.
    VELOCITY = 40

    WIDTH = 80
    HEIGHT = 24 # a bit more to enable collisions on slower computers

    # left:: x coordinate
    # ys:: Array of y coordinates between which the Lift
    #  will move. Note sort is applied onto this Array at first.
    # theme:: GfxTheme instance

    def initialize(left, ys, theme=NullGfxTheme.instance)
      super([left, ys[0]], theme)
      @theme = theme

      @image = get_theme_image 'bridge'
      @rect.w = @image.image.w

      @y = ys.sort      # Array of destinations created by Bridge.new

      init_transporter

      @dest = 0         # subscript of the next destination y
    end

    # Only for those who know the source code of the class well. 
    # Don't use this if 
    # you have another way to solve your problem! This is stinking!

    attr_writer :dest

    def solid?
      true
    end

    # Lift starts moving up if it isn't on the top of it's
    # route. Returns true or false.

    def move_up(who=nil)
      if @dest > 0 then
        @dest -= 1 
        return true
      end
      return false
    end

    # Lift starts moving down if it isn't on the low end of it's
    # route. Returns true or false.

    def move_down(who=nil)
      if @dest < (@y.size - 1) then
        @dest += 1
        return true
      end
      return false
    end

    # Starts moving to the next destination place. Calling this iterates 
    # through
    # the places from the bottom up and then jumps to the low end and starts
    # once more.
    #
    # It is useful mainly for two-y lifts.

    def next
      @dest = (@dest + 1) % @y.size
    end

    def update
      if in_destination?
        return
      end

      d = delta_y

      find_transported_sprites
      @rect.top += d
      move_transported_sprites 0, d
    end

    def location=(new_location)
      old_loc = @location
      super(new_location)

      # The TransportBridge is also an ActiveObject.
      # It's because it can be driven by the cursor keys.
      if new_location.kind_of? NullLocation
        old_loc.activeobjectmanager.delete self
      end
    end

    # == Active Object methods
    # Lift is also an Active object.
    # So the player can command it very intuitively by pressing 
    # up and down key.

    alias_method :activate, :move_up
    alias_method :deactivate, :move_down

    def register_in(location)
      location.add_static_object self
      location.add_sprite self
      location.add_active_object self
    end

    private

    def in_destination?
      @y[@dest] == @rect.top
    end

    def delta_y
      total_delta_y = (@y[@dest] - @rect.top)

      d = (total_delta_y.signum * VELOCITY * @location.ticker.delta).to_i

      if d.abs > total_delta_y.abs then
        return total_delta_y
      else
        return d
      end
    end
  end # class Lift
end # module FreeVikings

# A little extension of the built-in class
class Numeric
  def signum
    return 0 if self.to_i == 0
    return self / self.abs
  end
end
