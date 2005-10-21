# transporterbridge.rb
# igneus 6.10.2005

=begin
= NAME
TransporterBridge

= DESCRIPTION
(({TransporterBridge})) is a platform which can move up and down.
It is usually used as a lift. Any (({Sprite})) which includes 
(({Transportable})) can be given a lift by this lift.

= Superclass
Bridge
=end

require 'monsters/bridge.rb'
require 'gfxtheme.rb'
require 'transportable.rb'

module FreeVikings

  class TransporterBridge < Bridge

=begin
--- TransporterBridge::VELOCITY
abs of vertical velocity.
=end

    VELOCITY = 40

    WIDTH = 80
    HEIGHT = 24 # a bit more to enable collisions on slower computers

=begin
--- TransporterBridge.new(left, ys, theme=NullGfxTheme.instance)
:((|left|)) = x coordinate
:((|ys|)) = (({Array})) of y coordinates between which the TransporterBridge
 will move. Note (({sort})) is applied onto this (({Array})) at first.
:((|theme|)) = (({GfxTheme})) instance
=end

    def initialize(left, ys, theme=NullGfxTheme.instance)
      super([left, ys[0]])
      @theme = theme

      @image = get_theme_image 'bridge'
      @rect.w = @image.image.w

      @y = ys.sort      # Array of destinations created by Bridge.new

      @transported = [] # Array of the transported sprites

      @dest = 0         # subscript of the next destination y
    end

=begin
--- TransporterBridge#dest=(dest)
Only for those who know the source code of the class well. Don't use this if 
you have another way to solve your problem! This is stinking!
=end

    attr_writer :dest

=begin
--- TransporterBridge#move_up
(({TransporterBridge})) starts moving up if it isn't on the top of it's
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
--- TransporterBridge#move_down
(({TransporterBridge})) starts moving down if it isn't on the low end of it's
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
--- TransporterBridge#next
Starts moving to the next destination place. Calling this iterates through
the places from the bottom up and then jumps to the low end and starts
once more.

It is useful mainly for two-y lifts.
=end

    def next
      @dest = (@dest + 1) % @y.size
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

=begin
== Active Object methods
(({TransporterBridge})) is also an Active object.
So the player can command it very intuitively by pressing up and down key.

--- TransporterBridge#activate
Alias to ((<TransporterBridge#move_up>)).
=end

    alias_method :activate, :move_up
=begin
--- TransporterBridge#deactivate
Alias to ((<TransporterBridge#move_down>)).
=end

    alias_method :deactivate, :move_down

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
