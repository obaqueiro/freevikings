# textbox.rb
# igneus 24.9.2005

=begin
= TextBox
((<TextBox>)) is a box which contains a text (the most common is the box 
displayed when the helpbutton is used and the 'bubbles' displayed
during the talks).
=end

module FreeVikings

  class TextBox < Sprite
    
    DEFAULT_BACKGROUND_COLOUR = [0,0,0]
    DEFAULT_FOREGROUND_COLOUR = [255,255,255]
    WIDTH = 260
    DEFAULT_BORDER_WIDTH = 4
    
=begin
--- TextBox.new(position, text, foreground=DEFAULT_FOREGROUND_COLOUR, background=DEFAULT_BACKGROUND_COLOUR, border=DEFAULT_BORDER_WIDTH)
Both arguments should be clear, ((|text|)) is a simple (({String})).
=end

    def initialize(position, text, foreground=DEFAULT_FOREGROUND_COLOUR, background=DEFAULT_BACKGROUND_COLOUR, border=DEFAULT_BORDER_WIDTH)
      @text = text
      @foreground_colour = foreground
      @background_colour = background
      @border_width = border

      @text_renderer = FreeVikings::FONTS['default']

      super(position) # calls also init_images, creates @surface
      @rect = Rectangle.new(position[0]-@surface.w/2, 
                            position[1]-@surface.h/2, 
                            @surface.w, 
                            @surface.h)
    end
    
    def image
      @surface
    end

=begin
--- TextBox#in?
Says if the ((<TextBox>)) is inside some (({Location})) or not.
=end

    def in?
      @location.class == Location
    end

=begin
--- TextBox#disappear
Disappears from the (({Location})) instantly.
=end

    def disappear
      if self.in?
        @disappear_lock = nil
        @location.delete_sprite self
      end
    end
    
    def init_images
      width = WIDTH
      height = @text_renderer.height @text, width
      
      @surface = RUDL::Surface.new [width + 2*@border_width,
                                    height + 2*@border_width]
      @surface.fill @foreground_colour
      text_surface = RUDL::Surface.new [width, height]
      text_surface.fill @background_colour
      @text_renderer.render(text_surface, width, @text, @foreground_colour)
      @surface.blit text_surface, [@border_width, @border_width]
    end
  end # class TextBox

=begin
= DisappearingTextBox
((<DisappearingTextBox>)) is a ((<TextBox>)) which disappears after some time.
=end

  class DisappearingTextBox < TextBox

=begin
--- DisappearingTextBox.new(position, text, disappear_after=4, foreground=DEFAULT_FOREGROUND_COLOUR, background=DEFAULT_BACKGROUND_COLOUR, border=DEFAULT_BORDER_WIDTH)
((|disappear_after|)) is a number of seconds after which 
the ((<DisappearingTextBox>)) disappears automatically.
=end

    def initialize(position, text, disappear_after=4, foreground=DEFAULT_FOREGROUND_COLOUR, background=DEFAULT_BACKGROUND_COLOUR, border=DEFAULT_BORDER_WIDTH)
      super(position, text, foreground, background, border)
      @disappear_after = disappear_after
      @disappear_lock = nil
    end

    def update
      unless @disappear_lock
        @disappear_lock = TimeLock.new(@disappear_after, @location.ticker)
      end
      
      if @disappear_lock.free? then
        disappear
      end
    end
  end
end # module FreeVikings
