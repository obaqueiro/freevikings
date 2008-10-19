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

=begin
--- Lift::VELOCITY
abs of vertical velocity.
=end

    VELOCITY = 40

    WIDTH = 80
    HEIGHT = 24 # a bit more to enable collisions on slower computers

=begin
--- Lift.new(left, ys, theme=NullGfxTheme.instance)
:((|left|)) = x coordinate
:((|ys|)) = (({Array})) of y coordinates between which the Lift
 will move. Note (({sort})) is applied onto this (({Array})) at first.
:((|theme|)) = (({GfxTheme})) instance
=end

    def initialize(left, ys, theme=NullGfxTheme.instance)
      super([left, ys[0]], theme)
      #@theme = theme

      @image = get_theme_image 'bridge'
      @rect.w = @image.image.w

      @y = ys.sort      # Array of destinations created by Bridge.new

      init_transporter

      @dest = 0         # subscript of the next destination y
    end

=begin
--- Lift#dest=(dest)
Only for those who know the source code of the class well. Don't use this if 
you have another way to solve your problem! This is stinking!
=end

    attr_writer :dest

    def solid?
      true
    end

=begin
--- Lift#move_up
(({Lift})) starts moving up if it isn't on the top of it's
route. Returns ((|true|)) or ((|false|)).
=end

    def move_up
      if @dest > 0 then
        @dest -= 1 
        return true
      end
      return false
    end

=begin
--- Lift#move_down
(({Lift})) starts moving down if it isn't on the low end of it's
route. Returns ((|true|)) or ((|false|)).
=end

    def move_down
      if @dest < (@y.size - 1) then
        @dest += 1
        return true
      end
      return false
    end

=begin
--- Lift#next
Starts moving to the next destination place. Calling this iterates through
the places from the bottom up and then jumps to the low end and starts
once more.

It is useful mainly for two-y lifts.
=end

    def next
      @dest = (@dest + 1) % @y.size
    end

    def update
      old_rect = @rect.dup

      update_position

      delta_y = @rect.top - old_rect.top

      update_transported_sprites 0, delta_y
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

=begin
== Active Object methods
(({Lift})) is also an Active object.
So the player can command it very intuitively by pressing up and down key.

--- Lift#activate
Alias to ((<Lift#move_up>)).
=end

    alias_method :activate, :move_up
=begin
--- Lift#deactivate
Alias to ((<Lift#move_down>)).
=end

    alias_method :deactivate, :move_down

    def register_in(location)
      location.add_static_object self
      location.add_sprite self
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

  end # class Lift
end # module FreeVikings

# A little extension of the built-in class
class Numeric
  def signum
    return 0 if self.to_i == 0
    return self / self.abs
  end
end
