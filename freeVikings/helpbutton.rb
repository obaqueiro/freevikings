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

module FreeVikings

  class HelpButton < ActiveObject

    def initialize(initial_position, help_text, location=NullLocation.new)
      super(initial_position)
      @text = help_text
      @helpbox = HelpBox.new @rect, @text
    end

    def activate
      @location.map.static_objects.add @helpbox
    end

    def deactivate

    end

    def init_images
      @image = Image.load('help.tga')
    end

    class HelpBox < Entity

      BACKGROUND_COLOUR = [241,96,96]
      FOREGROUND_COLOUR = [255,255,255]
      WIDTH = 260
      BORDER_WIDTH = 8

      @@text_renderer = TextRenderer.new(FreeVikings::FONTS['big'])

      def initialize(position, text)
        super(position)

        width = WIDTH
        height = @@text_renderer.height text, width

        @rect.w = width
        @rect.h = height

        @surface = RUDL::Surface.new [width + 2*BORDER_WIDTH,
                                      height + 2*BORDER_WIDTH]
        @surface.fill FOREGROUND_COLOUR

        text_surface = RUDL::Surface.new [width, height]
        text_surface.fill BACKGROUND_COLOUR

        @@text_renderer.render(text_surface, width, text, FOREGROUND_COLOUR)

        @surface.blit text_surface, [BORDER_WIDTH, BORDER_WIDTH]
      end

      attr_reader :width
      attr_reader :height

      def image
        @surface
      end

      def solid
        false
      end
    end # class HelpBox
  end # class HelpButton
end # module FreeVikings
