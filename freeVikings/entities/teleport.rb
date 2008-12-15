# teleport.rb
# igneus 28.8.2008

module FreeVikings

  # Teleport is a place where you step in, press the 'S' button
  # and you are somewhere else - normally in another teleport...

  class Teleport < ActiveObject

    BASE_HEIGHT = 8

    WIDTH = 80
    HEIGHT = 120 - BASE_HEIGHT

    # Argument destination should be either position (Rectangle or Array)
    # or Teleport. It's a place, where a teleported viking shows up.

    def initialize(position, destination=nil)
      super(position)

      @collision_rect = @rect
      @paint_rect = @collision_rect.expand2(0,0,0,BASE_HEIGHT)

      self.destination = destination
    end

    # paint_rect and collision_rect are different!

    attr_reader :collision_rect
    attr_reader :paint_rect

    def destination=(d)
      if d != nil && !([Teleport, Rectangle, Array].find {|t| t == d.class})
        raise ArgumentError, "Unsupported Teleport destination type '#{d.class}'"
      end
      @destination = d
    end

    # Moves all Sprites which collide with the Teleport and have more than 50%
    # of their area on the Teleport.
    # (It's not a bug, it's a feature! You can teleport for example a monster -
    # if you are skilled enough...)

    def activate(who=nil)
      # If destination is undefined, teleport is unactive
      if ! has_destination? then
        return
      end

      @location.sprites_on_rect(self.rect).each do |s|
        if self.rect.common(s.rect).area >= (s.rect.area / 2) then
          teleport_sprite(s)
        end
      end
    end

    def image
      if has_destination? then
        return @active_image.image
      else
        return @inactive_image.image
      end
    end

    # Says if the Teleport has a destination

    def has_destination?
      ! @destination.nil?
    end

    private

    def destination
      if @destination.is_a? Teleport then
        return @destination.rect
      else
        # @destination is Rectangle or Array; if it isn't complete, we'll
        # fill it with zeros
        while @destination.size < 4 do
          @destination.push 0
        end
        return @destination
      end
    end

    # Teleports sprite to destination

    def teleport_sprite(s)
      d = destination
      x = d.left + d.w/2 - s.rect.w/2
      y = d.bottom - (s.rect.h + 1)

      s.rect.left = x
      s.rect.top = y
    end

    public

    # called from Entity#initialize

    def init_images
      @active_image = Image.load 'teleport_red.png'
      @inactive_image = Image.load 'teleport_green.png'
    end
  end # class Teleport
end # module FreeVikings
