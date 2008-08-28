# teleport.rb
# igneus 28.8.2008

module FreeVikings

  # Teleport is a place where you step in, press the 'S' button
  # and you are somewhere else - normally in another teleport...

  class Teleport < ActiveObject

    WIDTH = 80
    HEIGHT = 120

    # Argument destination should be either position (Rectangle or Array)
    # or Teleport. It's a place, where a teleported viking shows up.

    def initialize(position, destination=nil)
      super(position)

      self.destination = destination
    end

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

    def activate
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
      y = d.bottom - s.rect.h

      s.rect.left = x
      s.rect.top = y
    end

    public

    # called from Entity#initialize

    def init_images
      # create a pseudo-image:
      sa = RUDL::Surface.new [WIDTH, HEIGHT]
      sa.fill [10,50,250]

      si  = RUDL::Surface.new [WIDTH, HEIGHT]
      sa.fill [10,150,200]

      @active_image = Image.wrap sa
      @inactive_image = Image.wrap si
    end
  end # class Teleport
end # module FreeVikings
