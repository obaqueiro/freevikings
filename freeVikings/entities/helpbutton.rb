# helpbutton.rb
# igneus 24.7.2005


require 'gameui/textrenderer/textrenderer.rb'
require 'textbox.rb'

module FreeVikings

  # HelpButton is the well-known button with a red question mark. It usually 
  # gives 
  # the player short useful information about the new vehicle which hasn't been
  # used in any level before.

  class HelpButton < ActiveObject

    @@shown_helpbox = nil # last shown helpbox

    # Takes the last displayed HelpButton::HelpBox out and displays 
    # the new one.

    def HelpButton.show_new_helpbox(new_helpbox, location)
      if @@shown_helpbox and @@shown_helpbox.in? then
        @@shown_helpbox.disappear
      end

      @@shown_helpbox = new_helpbox
      location.add_sprite new_helpbox unless new_helpbox.in?
    end

    # Creates a new HelpButton which, when pressed, shows text help_text.
    # Argument location must be a valid Location where the help text will
    # be shown.

    def initialize(initial_position, help_text, location=NullLocation.instance)
      super(initial_position)
      @helpbox = HelpBox.new [@rect.center[0], @rect.center[1]-100], help_text
      @location = location
    end

    # Shows the help text (or hides it, if it is being shown).

    def activate(who=nil)
      unless @helpbox.in?
        HelpButton.show_new_helpbox @helpbox, @location
      else
        deactivate
      end
    end

    # Makes the help text disappear.

    def deactivate(who=nil)
      if @helpbox.in? then
        @helpbox.disappear
      end
    end

    def init_images
      @image = Image.load('help_button.png')
    end

    # This class is fully stand-alone, but it is defined inside HelpButton,
    # because it's only used from inside of it.
    # HelpBox is a simple Sprite which shows a help text and disappears
    # after HelpBox::DISAPPEAR_AFTER seconds.

    class HelpBox < DisappearingTextBox

      BACKGROUND_COLOUR = [200,0,0]
      FOREGROUND_COLOUR = [255,255,255]
      WIDTH = 260
      BORDER_WIDTH = 4

      # Number of seconds. For such a long time the text is shown, 
      # then it disappears.

      DISAPPEAR_AFTER = 7

      # Both arguments should be clear, text is a simple String.

      def initialize(position, text)
        super(position, text, DISAPPEAR_AFTER, FOREGROUND_COLOUR, BACKGROUND_COLOUR, BORDER_WIDTH)
      end
    end # class HelpBox
  end # class HelpButton
end # module FreeVikings
