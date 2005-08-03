# helpbutton.rb
# igneus 24.7.2005

=begin
= HelpButton
HelpButton is the well-known button with a red question mark. It usually gives 
the player short useful information about the new vehicle which hasn't been
used in any level before.
=end

require 'activeobject.rb'
require 'textrenderer.rb'
require 'timelock.rb'

module FreeVikings

  class HelpButton < ActiveObject

    def initialize(initial_position, help_text, location=NullLocation.instance)
      super(initial_position)
      @helpbox = HelpBox.new @rect, help_text
      @location = location
    end

    def activate
      @location.add_sprite @helpbox unless @helpbox.in?
    end

    def deactivate
    end

    def init_images
      @image = Image.load('help.tga')
    end

    class HelpBox < Sprite

      BACKGROUND_COLOUR = [241,96,96]
      FOREGROUND_COLOUR = [255,255,255]
      WIDTH = 260
      BORDER_WIDTH = 8

      DISAPPEAR_AFTER = 7

      @@text_renderer = TextRenderer.new(RUDL::TrueTypeFont.new('fonts/adlibn.ttf', 16))

      def initialize(position, text)
        @text = text
        super(position)
        @rect = Rectangle.new(position[0]-@surface.w/2, 
                              position[1]-@surface.h/2, 
                              @surface.w, 
                              @surface.h)
        @disappear_lock = nil
      end

      def update
        unless @disappear_lock
          @disappear_lock = TimeLock.new(DISAPPEAR_AFTER, @location.ticker)
        end

        if @disappear_lock.free? then
          @disappear_lock = nil
          @location.delete_sprite self
        end
      end

      def image
        @surface
      end

      def in?
        @location.class == Location
      end

      def init_images
        width = WIDTH
        height = @@text_renderer.height @text, width

        @surface = RUDL::Surface.new [width + 2*BORDER_WIDTH,
                                      height + 2*BORDER_WIDTH]
        @surface.fill FOREGROUND_COLOUR
        text_surface = RUDL::Surface.new [width, height]
        text_surface.fill BACKGROUND_COLOUR
        @@text_renderer.render(text_surface, width, @text, FOREGROUND_COLOUR)
        @surface.blit text_surface, [BORDER_WIDTH, BORDER_WIDTH]
      end
    end # class HelpBox
  end # class HelpButton
end # module FreeVikings
