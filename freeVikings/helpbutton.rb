# helpbutton.rb
# igneus 24.7.2005

=begin
= HelpButton
HelpButton is the well-known button with a red question mark. It usually gives 
the player short useful information about the new vehicle which hasn't been
used in any level before.
=end

require 'gameui/textrenderer/textrenderer.rb'
require 'textbox.rb'

module FreeVikings

  class HelpButton < ActiveObject

    @@shown_helpbox = nil # last shown helpbox

=begin
--- HelpButton.show_new_helpbox(new_helpbox, location)
Takes the last displayed ((<HelpButton::HelpBox>)) out and displays 
the new one.
=end

    def HelpButton.show_new_helpbox(new_helpbox, location)
      if @@shown_helpbox and @@shown_helpbox.in? then
        @@shown_helpbox.disappear
      end

      @@shown_helpbox = new_helpbox
      location.add_sprite new_helpbox unless new_helpbox.in?
    end

=begin
--- HelpButton.new(initial_position, help_text, location=NullLocation.instance)
Creates a new ((<HelpButton>)) which, when pressed, shows text ((|help_text|)).
Argument ((|location|)) must be a valid (({Location})) where the help text will
be shown.
=end

    def initialize(initial_position, help_text, location=NullLocation.instance)
      super(initial_position)
      @helpbox = HelpBox.new @rect, help_text
      @location = location
    end

=begin
--- HelpButton#activate
Shows the help text.
=end

    def activate
      HelpButton.show_new_helpbox @helpbox, @location
    end

=begin
--- HelpButton#deactivate
Does nothing.
=end

    def deactivate
    end

    def init_images
      @image = Image.load('help.tga')
    end

=begin
= HelpButton::HelpBox
This class is fully stand-alone, but it is defined inside ((<HelpButton>)),
because it's only used from inside of it.
HelpBox is a simple (({Sprite})) which shows a help text and disappears
after ((<HelpBox::DISAPPEAR_AFTER>)) seconds.
=end

    class HelpBox < DisappearingTextBox

      BACKGROUND_COLOUR = [241,96,96]
      FOREGROUND_COLOUR = [255,255,255]
      WIDTH = 260
      BORDER_WIDTH = 8

=begin
--- HelpBox::DISAPPEAR_AFTER
Number of seconds. For such a long time the text is shown, then it disappears.
=end

      DISAPPEAR_AFTER = 7

=begin
--- HelpBox.new(position, text)
Both arguments should be clear, ((|text|)) is a simple (({String})).
=end

      def initialize(position, text)
        super(position, text, DISAPPEAR_AFTER, FOREGROUND_COLOUR, BACKGROUND_COLOUR, BORDER_WIDTH)
      end
    end # class HelpBox
  end # class HelpButton
end # module FreeVikings
